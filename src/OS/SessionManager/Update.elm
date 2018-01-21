module OS.SessionManager.Update exposing (update)

import Dict exposing (Dict)
import Utils.Maybe as Maybe
import Core.Error as Error
import Utils.React as React exposing (React)
import OS.SessionManager.Config exposing (..)
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Helpers exposing (..)
import OS.SessionManager.Launch exposing (..)
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.Dock.Update as Dock
import OS.SessionManager.Dock.Messages as Dock
import OS.SessionManager.WindowManager.Update as WM
import OS.SessionManager.WindowManager.Models as WM
import OS.SessionManager.WindowManager.Messages as WM
import Game.Meta.Types.Context exposing (Context(..))
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Apps.Messages as Apps
import Apps.Apps as Apps
import Apps.Launch as Apps
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    let
        id =
            getSessionID config

        model_ =
            ensureSession id model
    in
        case msg of
            HandleNewApp context params app ->
                handleNewApp config id context params app model_

            HandleOpenApp context params ->
                handleOpenApp config id context params model_

            WindowManagerMsg id msg ->
                onWindowManagerMsg config id msg model_

            DockMsg msg ->
                onDockMsg config id msg model_

            AppMsg ( sessionId, windowId ) context msg ->
                onWindowManagerMsg
                    config
                    sessionId
                    (WM.AppMsg (WM.One context) windowId msg)
                    model

            EveryAppMsg msgs ->
                onEveryAppMsg config msgs model_

            TargetedAppMsg targetCid targetContext msgs ->
                onTargetedAppMsg config targetCid targetContext msgs model_



-- internals


type alias UpdateResponse msg =
    ( Model, React msg )


handleNewApp :
    Config msg
    -> ID
    -> Maybe Context
    -> Maybe Apps.AppParams
    -> Apps.App
    -> Model
    -> UpdateResponse msg
handleNewApp config id context params app model =
    let
        ip =
            config.endpointCId

        config_ =
            wmConfig id config

        ( model_, cmd, dispatch ) =
            openApp config_ context params id ip app model

        cmd_ =
            Cmd.map config.toMsg cmd
    in
        ( model_, cmd_, dispatch )


handleOpenApp :
    Config msg
    -> ID
    -> Maybe Context
    -> Apps.AppParams
    -> Model
    -> UpdateResponse msg
handleOpenApp config id maybeContext params model =
    let
        app =
            Apps.paramsToApp params

        context =
            case maybeContext of
                Just context ->
                    context

                Nothing ->
                    config.activeContext

        maybeWm =
            get id model

        maybeWindowId =
            Maybe.andThen (findApp app) maybeWm
    in
        case maybeWindowId of
            Just windowId ->
                params
                    |> Apps.launchEvent context
                    |> WM.AppMsg (WM.One context) windowId
                    |> flip (onWindowManagerMsg config id) model

            Nothing ->
                handleNewApp config id maybeContext (Just params) app model


onWindowManagerMsg :
    Config msg
    -> ID
    -> WM.Msg
    -> Model
    -> UpdateResponse msg
onWindowManagerMsg config id msg model =
    let
        wm =
            case get id (ensureSession id model) of
                Just wm ->
                    wm

                Nothing ->
                    Debug.crash ""

        config_ =
            wmConfig id config

        ( wm_, cmd, dispatch ) =
            WM.update config_ msg wm

        model_ =
            refresh id wm_ model
    in
        ( model_, cmd, dispatch )


onDockMsg : Config msg -> ID -> Dock.Msg -> Model -> UpdateResponse msg
onDockMsg config id msg model_ =
    let
        config_ =
            dockConfig id config

        ( model, cmd, dispatch ) =
            Dock.update config_ msg model_

        cmd_ =
            Cmd.map config.toMsg cmd
    in
        ( model, cmd_, dispatch )


{-| Sends messages to every opened app on every session
-}
onEveryAppMsg :
    Config msg
    -> List Apps.Msg
    -> Model
    -> UpdateResponse msg
onEveryAppMsg config appMsgs model =
    let
        toWmMsg =
            WM.EveryAppMsg WM.All

        ( model_, cmd, dispatch ) =
            Dict.foldl (reduceSessions config appMsgs toWmMsg)
                ( model, Cmd.none, Dispatch.none )
                model.sessions
    in
        ( model_, cmd, dispatch )


{-| Sends messages to apps inside related sessions
-}
onTargetedAppMsg :
    Config msg
    -> Servers.CId
    -> WM.TargetContext
    -> List Apps.Msg
    -> Model
    -> UpdateResponse msg
onTargetedAppMsg config targetCid targetContext appMsgs model =
    let
        servers =
            config.servers

        filterer =
            case targetContext of
                WM.One Gateway ->
                    filterGatewaySessions

                WM.One Endpoint ->
                    filterEndpointRelatedSessions servers

                WM.All ->
                    filterRelatedSessions servers

                WM.Active ->
                    filterRelatedSessions servers

        filter sid wm =
            sid
                |> Servers.fromKey
                |> flip (filterer targetCid) wm

        toWmMsg =
            WM.EveryAppMsg targetContext

        foldl =
            Dict.foldl (reduceSessions config appMsgs toWmMsg)
                ( model, Cmd.none, Dispatch.none )

        -- filter sessions and apply the messages
        ( model_, cmd, dispatch ) =
            model
                |> filterSessions filter
                |> foldl
    in
        ( model_, cmd, dispatch )



-- helpers


findApp : Apps.App -> WM.Model -> Maybe WM.ID
findApp app wm =
    let
        filter =
            WM.filterApp app wm.windows

        maybeFound =
            wm.visible
                |> List.filter filter
                |> List.head
    in
        case maybeFound of
            Just found ->
                Just found

            Nothing ->
                wm.hidden
                    |> List.filter filter
                    |> List.head


{-| A reduce helper that routes messages to apps.
-}
reduceMessages :
    Config msg
    -> (Apps.Msg -> WM.Msg)
    -> ID
    -> WM.Model
    -> Apps.Msg
    -> ( Model, List (Cmd msg), List Dispatch )
    -> ( Model, List (Cmd msg), List Dispatch )
reduceMessages config toWmMsg sid wm msg ( model, cmds, disps ) =
    let
        msg_ =
            toWmMsg msg

        config_ =
            wmConfig sid config

        ( wm_, cmd, disp ) =
            WM.update config_ msg_ wm

        model_ =
            refresh sid wm_ model

        cmds_ =
            cmd :: cmds

        disps_ =
            disp :: disps
    in
        ( model_, cmds_, disps_ )


{-| A reduce helper that routes messages to sessions.
-}
reduceSessions :
    Config msg
    -> List Apps.Msg
    -> (Apps.Msg -> WM.Msg)
    -> ID
    -> WM.Model
    -> ( Model, Cmd msg, Dispatch )
    -> ( Model, Cmd msg, Dispatch )
reduceSessions config appMsgs toWmMsg sid wm ( model, cmd, disp ) =
    let
        ( model_, cmds, disps ) =
            List.foldl (reduceMessages config toWmMsg sid wm)
                ( model, [], [] )
                appMsgs

        cmd_ =
            Cmd.batch
                [ Cmd.batch cmds
                , cmd
                ]

        disp_ =
            Dispatch.batch [ Dispatch.batch disps, disp ]
    in
        ( model_, cmd_, disp_ )


{-| A filterer that keeps sessions of following gateway.
-}
filterGatewaySessions :
    Servers.CId
    -> Servers.CId
    -> WM.Model
    -> Bool
filterGatewaySessions targetCid cid wm =
    -- this is the session of the targeted gateway
    targetCid == cid


{-| A filterer that keeps related sessions.
-}
filterRelatedSessions :
    Servers.Model
    -> Servers.CId
    -> Servers.CId
    -> WM.Model
    -> Bool
filterRelatedSessions servers targetCid cid wm =
    if targetCid == cid then
        -- this is the session of the target
        True
    else
        -- this session is related to the target
        servers
            |> Servers.get cid
            |> Maybe.andThen Servers.getEndpoints
            |> Maybe.map (List.member targetCid)
            |> Maybe.withDefault False


{-| A filterer that keeps sessions related to the endpoint.
-}
filterEndpointRelatedSessions :
    Servers.Model
    -> Servers.CId
    -> Servers.CId
    -> WM.Model
    -> Bool
filterEndpointRelatedSessions servers targetCid cid wm =
    if targetCid == cid then
        -- this is the session of the targeted endpoint
        True
    else
        -- this session is accessing the targeted endpoint
        let
            maybeServer =
                Servers.get cid servers

            maybeIsGateway =
                Maybe.map Servers.isGateway maybeServer
        in
            case Maybe.uncurry maybeServer maybeIsGateway of
                Just ( server, isGateway ) ->
                    if isGateway then
                        -- this server is a gateway accessing the target
                        server
                            |> Servers.getEndpoints
                            |> Maybe.map (List.member targetCid)
                            |> Maybe.withDefault False
                    else
                        False

                Nothing ->
                    False


getSessionID : Config msg -> ID
getSessionID config =
    case config.activeContext of
        Gateway ->
            config.activeServer
                |> Tuple.first
                |> Servers.toSessionId

        Endpoint ->
            let
                endpointSessionId =
                    config.activeServer
                        |> Tuple.second
                        |> Servers.getEndpointCId
                        |> Maybe.map Servers.toSessionId
            in
                case endpointSessionId of
                    Just endpointSessionId ->
                        endpointSessionId

                    Nothing ->
                        "U = {x}, ∄ x ⊂ U"
                            |> Error.neeiae
                            |> uncurry Native.Panic.crash
