module OS.SessionManager.WindowManager.Launch exposing (resert, insert)

import Dict
import Utils.React as React exposing (React)
import Game.Models as Game
import Game.Account.Models as Account
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Shared as Servers
import OS.SessionManager.WindowManager.Config exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models exposing (..)
import Apps.Apps as Apps
import Apps.Models as Apps
import Apps.Launch as Apps


resert :
    Config msg
    -> Maybe Context
    -> Maybe Apps.AppParams
    -> String
    -> Maybe Servers.CId
    -> Apps.App
    -> Model
    -> ( Model, React msg )
resert config maybeContext maybeParams id serverCId app model =
    -- TODO: maybe check if the opened window has the current endpoint, focus
    -- it if this is the case
    let
        { visible, hidden, windows } =
            model

        noVisible =
            visible
                |> List.filter (filterApp app windows)
                |> List.isEmpty

        noHidden =
            hidden
                |> List.filter (filterApp app windows)
                |> List.isEmpty

        noOpened =
            noVisible && noHidden
    in
        if noVisible && (not noHidden) then
            let
                model_ =
                    hidden
                        |> List.filter (filterApp app windows)
                        |> List.foldl restore model
            in
                ( model_, React.none )
        else
            insert config maybeContext maybeParams id serverCId app model


insert :
    Config msg
    -> Maybe Context
    -> Maybe Apps.AppParams
    -> ID
    -> Maybe Servers.CId
    -> Apps.App
    -> Model
    -> ( Model, React msg )
insert config maybeContext maybeParams id serverCId app model =
    let
        { windows, visible, parentSession } =
            model

        ( instance, react ) =
            case Apps.contexts app of
                Apps.ContextualApp ->
                    let
                        context =
                            fallbackContext config maybeContext

                        ( gatewayParams, endpointParams ) =
                            case context of
                                Gateway ->
                                    ( maybeParams, Nothing )

                                Endpoint ->
                                    ( Nothing, maybeParams )

                        gatewayConfig =
                            appsConfig config.activeGateway id (One Gateway) config

                        endpointConfig =
                            appsConfig
                                (unsafeContextServer config context)
                                id
                                (One Endpoint)
                                config

                        ( modelG, reactG ) =
                            Apps.launch gatewayConfig
                                { sessionId = parentSession
                                , windowId = id
                                , context = Gateway
                                }
                                gatewayParams
                                app

                        ( modelE, reactE ) =
                            Apps.launch endpointConfig
                                { sessionId = parentSession
                                , windowId = id
                                , context = Endpoint
                                }
                                endpointParams
                                app

                        react =
                            React.batch config.batchMsg [ reactG, reactE ]

                        model =
                            DoubleContext context modelG modelE
                    in
                        ( model, react )

                Apps.ContextlessApp ->
                    let
                        config_ =
                            appsConfig config.activeGateway id (One Gateway) config

                        ( model, react ) =
                            Apps.launch config_
                                { sessionId = parentSession
                                , windowId = id
                                , context = Gateway
                                }
                                maybeParams
                                app
                    in
                        ( SingleContext model, react )

        window =
            Window
                (initialPosition model)
                (uncurry Size <| Apps.windowInitSize app)
                False
                app
                instance
                False
                serverCId

        windows_ =
            Dict.insert id window windows

        visible_ =
            moveTail id visible

        model_ =
            { model
                | windows = windows_
                , visible = visible_
                , focusing = Just id
            }
    in
        ( model_, react )



-- helpers


fallbackContext : Config msg -> Maybe Context -> Context
fallbackContext config maybeContext =
    case maybeContext of
        Just context ->
            context

        Nothing ->
            config.activeContext
