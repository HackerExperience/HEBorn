module OS.SessionManager.Update exposing (update)

import Dict exposing (Dict)
import Utils.Update as Update
import Utils.Maybe as Maybe
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Helpers exposing (..)
import OS.SessionManager.Launch exposing (..)
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.Dock.Update as Dock
import OS.SessionManager.WindowManager.Update as WM
import OS.SessionManager.WindowManager.Models as WM
import OS.SessionManager.WindowManager.Messages as WM
import Game.Meta.Types exposing (Context(..))
import OS.SessionManager.Types exposing (..)
import Game.Data as Game
import Game.Models as Game
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Apps.Messages as Apps
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Game.Data
    -> Msg
    -> Model
    -> UpdateResponse
update data msg model =
    let
        id =
            toSessionID data

        model_ =
            ensureSession data id model
    in
        case msg of
            EveryAppMsg msgs ->
                onEveryAppMsg data msgs model_

            TargetedAppMsg targetCid targetContext msgs ->
                onTargetedAppMsg data targetCid targetContext msgs model_

            WindowManagerMsg id msg ->
                windowManager data id msg model_

            DockMsg msg ->
                Dock.update data msg model_

            AppMsg ( sessionId, windowId ) context msg ->
                windowManager data
                    sessionId
                    (WM.AppMsg (WM.One context) windowId msg)
                    model



-- internals


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


windowManager :
    Game.Data
    -> ID
    -> WM.Msg
    -> Model
    -> UpdateResponse
windowManager data id msg model =
    let
        wm =
            case get id (ensureSession data id model) of
                Just wm ->
                    wm

                Nothing ->
                    Debug.crash "WTF"

        ( wm_, cmd, dispatch ) =
            WM.update data msg wm

        model_ =
            refresh id wm_ model

        cmd_ =
            Cmd.map (WindowManagerMsg id) cmd
    in
        ( model_, cmd_, dispatch )


ensureSession : Game.Data -> ID -> Model -> Model
ensureSession data id model =
    case get id model of
        Just _ ->
            model

        Nothing ->
            insert id model


onEveryAppMsg :
    Game.Data
    -> List Apps.Msg
    -> Model
    -> UpdateResponse
onEveryAppMsg data msgs model =
    let
        -- send messages to the window manager
        reduceMessages sid wm message ( model, cmds, disps ) =
            let
                message_ =
                    WM.EveryAppMsg WM.All message

                ( wm_, cmd, disp ) =
                    WM.update data message_ wm

                model_ =
                    refresh sid wm_ model

                cmds_ =
                    cmd :: cmds

                disps_ =
                    disp :: disps
            in
                ( model_, cmds_, disps_ )

        -- route messages to related sessions
        reduceSessions sid wm ( model, cmd, disp ) =
            let
                ( model_, cmds, disps ) =
                    List.foldl (reduceMessages sid wm)
                        ( model, [], [] )
                        msgs

                cmd_ =
                    Cmd.batch
                        [ Cmd.map (WindowManagerMsg sid) <| Cmd.batch cmds
                        , cmd
                        ]

                disp_ =
                    Dispatch.batch [ Dispatch.batch disps, disp ]
            in
                ( model_, cmd_, disp_ )

        -- apply messages
        ( model_, cmd, dispatch ) =
            Dict.foldl reduceSessions
                ( model, Cmd.none, Dispatch.none )
                model.sessions
    in
        ( model_, cmd, dispatch )


onTargetedAppMsg :
    Game.Data
    -> Servers.ID
    -> WM.TargetContext
    -> List Apps.Msg
    -> Model
    -> UpdateResponse
onTargetedAppMsg data targetCid targetContext msgs model =
    let
        servers =
            data
                |> Game.getGame
                |> Game.getServers

        -- a simple filter for gateway targets
        filtererForGateway cid wm =
            if targetCid == cid then
                -- this is the session we want
                True
            else
                -- this session is being accessed from the our gateway target
                servers
                    |> Servers.get targetCid
                    |> Maybe.andThen Servers.getEndpoints
                    |> Maybe.map (List.member cid)
                    |> Maybe.withDefault False

        -- a complex filter for endpoint targets
        filtererForEndpoint cid wm =
            if targetCid == cid then
                -- this is the endpoint we want
                True
            else
                -- this targeted endpoint is being accessed from this gateway
                let
                    maybeServer =
                        Servers.get cid servers

                    maybeIsGateway =
                        Maybe.map Servers.isGateway maybeServer
                in
                    case Maybe.uncurry maybeServer maybeIsGateway of
                        Just ( server, isGateway ) ->
                            if isGateway then
                                -- this server is a gateway that includes
                                -- the targeted endpoint
                                server
                                    |> Servers.getEndpoints
                                    |> Maybe.map (List.member targetCid)
                                    |> Maybe.withDefault False
                            else
                                False

                        Nothing ->
                            False

        -- select the desired session filter
        filterer =
            case targetContext of
                WM.One Gateway ->
                    (\cid wm -> targetCid == cid)

                WM.One Endpoint ->
                    filtererForEndpoint

                _ ->
                    -- accept *any* session related to our target
                    (\cid wm ->
                        if targetCid == cid then
                            True
                        else
                            servers
                                |> Servers.get cid
                                |> Maybe.andThen Servers.getEndpoints
                                |> Maybe.map (List.member targetCid)
                                |> Maybe.withDefault False
                    )

        -- send messages to the window manager
        reduceMessages sid wm message ( model, cmds, disps ) =
            let
                message_ =
                    WM.EveryAppMsg targetContext message

                ( wm_, cmd, disp ) =
                    WM.update data message_ wm

                model_ =
                    refresh sid wm_ model

                cmds_ =
                    cmd :: cmds

                disps_ =
                    disp :: disps
            in
                ( model_, cmds_, disps_ )

        -- route messages to related sessions
        reduceSessions sid wm ( model, cmd, disp ) =
            let
                ( model_, cmds, disps ) =
                    List.foldl (reduceMessages sid wm)
                        ( model, [], [] )
                        msgs

                cmd_ =
                    Cmd.batch
                        [ Cmd.map (WindowManagerMsg sid) <| Cmd.batch cmds
                        , cmd
                        ]

                disp_ =
                    Dispatch.batch [ Dispatch.batch disps, disp ]
            in
                ( model_, cmd_, disp_ )

        -- forward cid to the filter function
        getCidForSid func sid wm =
            case Servers.fromKey sid servers of
                Just cid ->
                    func cid wm

                Nothing ->
                    False

        -- filter sessions and apply the messages
        ( model_, cmd, dispatch ) =
            model
                |> filterSessions (getCidForSid filterer)
                |> Dict.foldl reduceSessions
                    ( model, Cmd.none, Dispatch.none )
    in
        ( model_, cmd, dispatch )
