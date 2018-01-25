module OS.SessionManager.Update exposing (update)

import Dict exposing (Dict)
import Utils.Maybe as Maybe
import Utils.React as React exposing (React)
import OS.SessionManager.Config exposing (..)
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Launch exposing (..)
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.Dock.Update as Dock
import OS.SessionManager.Dock.Messages as Dock
import OS.SessionManager.WindowManager.Update as WM
import OS.SessionManager.WindowManager.Models as WM
import OS.SessionManager.WindowManager.Messages as WM
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Apps.Messages as Apps
import Apps.Apps as Apps
import Apps.Launch as Apps


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

        ( model_, react ) =
            openApp config_ context params id ip app model
    in
        ( model_, react )


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

        ( wm_, react ) =
            WM.update config_ msg wm

        model_ =
            refresh id wm_ model
    in
        ( model_, react )


onDockMsg : Config msg -> ID -> Dock.Msg -> Model -> UpdateResponse msg
onDockMsg config id =
    Dock.update (dockConfig id config)


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

        ( model_, react ) =
            Dict.foldl (reduceSessions config appMsgs toWmMsg)
                ( model, React.none )
                model.sessions
    in
        ( model_, react )


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
                ( model, React.none )

        -- filter sessions and apply the messages
        ( model_, react ) =
            model
                |> filterSessions filter
                |> foldl
    in
        ( model_, react )



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
    -> ( Model, List (React msg) )
    -> ( Model, List (React msg) )
reduceMessages config toWmMsg sid wm msg ( model, reacts ) =
    let
        msg_ =
            toWmMsg msg

        config_ =
            wmConfig sid config

        ( wm_, react ) =
            WM.update config_ msg_ wm

        model_ =
            refresh sid wm_ model

        reacts_ =
            react :: reacts
    in
        ( model_, reacts_ )


{-| A reduce helper that routes messages to sessions.
-}
reduceSessions :
    Config msg
    -> List Apps.Msg
    -> (Apps.Msg -> WM.Msg)
    -> ID
    -> WM.Model
    -> ( Model, React msg )
    -> ( Model, React msg )
reduceSessions config appMsgs toWmMsg sid wm ( model, react ) =
    let
        ( model_, reacts ) =
            List.foldl (reduceMessages config toWmMsg sid wm)
                ( model, [] )
                appMsgs

        react_ =
            React.batch
                config.batchMsg
                (react :: reacts)
    in
        ( model_, react_ )


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
    config.activeServer
        |> Tuple.first
        |> Servers.toSessionId
