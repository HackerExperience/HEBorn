module OS.SessionManager.Update exposing (update)

import Dict exposing (Dict)
import Utils.Maybe as Maybe
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
import Game.Data as Game
import Game.Models
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Apps.Messages as Apps
import Apps.Apps as Apps
import Apps.Launch as Apps
import Core.Dispatch as Dispatch exposing (Dispatch)


-- CONFREFACT: remove Game.Data after refactor


update :
    Config msg
    -> Game.Data
    -> Msg
    -> Model
    -> UpdateResponse msg
update config data msg model =
    let
        id =
            toSessionID data

        model_ =
            ensureSession id model
    in
        case msg of
            HandleNewApp context params app ->
                handleNewApp config data id context params app model_

            HandleOpenApp context params ->
                handleOpenApp config data id context params model_

            WindowManagerMsg id msg ->
                onWindowManagerMsg config data id msg model_

            DockMsg msg ->
                onDockMsg config data msg model_

            AppMsg ( sessionId, windowId ) context msg ->
                onWindowManagerMsg config
                    data
                    sessionId
                    (WM.AppMsg (WM.One context) windowId msg)
                    model

            EveryAppMsg msgs ->
                onEveryAppMsg config data msgs model_

            TargetedAppMsg targetCid targetContext msgs ->
                onTargetedAppMsg config data targetCid targetContext msgs model_



-- internals


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


handleNewApp :
    Config msg
    -> Game.Data
    -> ID
    -> Maybe Context
    -> Maybe Apps.AppParams
    -> Apps.App
    -> Model
    -> UpdateResponse msg
handleNewApp config data id context params app model =
    let
        ip =
            data
                |> Game.getActiveServer
                |> Servers.getEndpointCId

        ( model_, cmd, dispatch ) =
            openApp data context params id ip app model

        cmd_ =
            Cmd.map config.toMsg cmd
    in
        ( model_, cmd_, dispatch )


handleOpenApp :
    Config msg
    -> Game.Data
    -> ID
    -> Maybe Context
    -> Apps.AppParams
    -> Model
    -> UpdateResponse msg
handleOpenApp config data id maybeContext params model =
    let
        app =
            Apps.paramsToApp params

        context =
            case maybeContext of
                Just context ->
                    context

                Nothing ->
                    data
                        |> Game.getGame
                        |> Game.Models.getAccount
                        |> Account.getContext

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
                    |> flip (onWindowManagerMsg config data id) model

            Nothing ->
                handleNewApp config data id maybeContext (Just params) app model


onWindowManagerMsg :
    Config msg
    -> Game.Data
    -> ID
    -> WM.Msg
    -> Model
    -> UpdateResponse msg
onWindowManagerMsg config data id msg model =
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
            WM.update config_ data msg wm

        model_ =
            refresh id wm_ model
    in
        ( model_, cmd, dispatch )


onDockMsg : Config msg -> Game.Data -> Dock.Msg -> Model -> UpdateResponse msg
onDockMsg config data msg model_ =
    let
        config_ =
            dockConfig config

        ( model, cmd, dispatch ) =
            Dock.update config_ data msg model_

        cmd_ =
            Cmd.map config.toMsg cmd
    in
        ( model, cmd_, dispatch )


{-| Sends messages to every opened app on every session
-}
onEveryAppMsg :
    Config msg
    -> Game.Data
    -> List Apps.Msg
    -> Model
    -> UpdateResponse msg
onEveryAppMsg config data appMsgs model =
    let
        toWmMsg =
            WM.EveryAppMsg WM.All

        ( model_, cmd, dispatch ) =
            Dict.foldl (reduceSessions config data appMsgs toWmMsg)
                ( model, Cmd.none, Dispatch.none )
                model.sessions
    in
        ( model_, cmd, dispatch )


{-| Sends messages to apps inside related sessions
-}
onTargetedAppMsg :
    Config msg
    -> Game.Data
    -> Servers.CId
    -> WM.TargetContext
    -> List Apps.Msg
    -> Model
    -> UpdateResponse msg
onTargetedAppMsg config data targetCid targetContext appMsgs model =
    let
        servers =
            data
                |> Game.getGame
                |> Game.Models.getServers

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
            Dict.foldl (reduceSessions config data appMsgs toWmMsg)
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
    -> Game.Data
    -> (Apps.Msg -> WM.Msg)
    -> ID
    -> WM.Model
    -> Apps.Msg
    -> ( Model, List (Cmd msg), List Dispatch )
    -> ( Model, List (Cmd msg), List Dispatch )
reduceMessages config data toWmMsg sid wm msg ( model, cmds, disps ) =
    let
        msg_ =
            toWmMsg msg

        config_ =
            wmConfig sid config

        ( wm_, cmd, disp ) =
            WM.update config_ data msg_ wm

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
    -> Game.Data
    -> List Apps.Msg
    -> (Apps.Msg -> WM.Msg)
    -> ID
    -> WM.Model
    -> ( Model, Cmd msg, Dispatch )
    -> ( Model, Cmd msg, Dispatch )
reduceSessions config data appMsgs toWmMsg sid wm ( model, cmd, disp ) =
    let
        ( model_, cmds, disps ) =
            List.foldl (reduceMessages config data toWmMsg sid wm)
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
