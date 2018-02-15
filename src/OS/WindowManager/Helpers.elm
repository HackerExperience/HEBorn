module OS.WindowManager.Helpers exposing (..)

import Apps.Shared as Apps exposing (AppContext)
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared as Servers exposing (CId(..))
import OS.WindowManager.Config exposing (..)
import OS.WindowManager.Models exposing (..)
import OS.WindowManager.Shared exposing (..)


newInstance :
    Config msg
    -> DesktopApp
    -> Context
    -> Model
    -> ( Model, Instance )
newInstance config desktopApp context model =
    let
        ( model1, appId1 ) =
            newAppId model

        ( model2, appId2 ) =
            newAppId model1
    in
        case Apps.context desktopApp of
            Apps.DynamicContext ->
                case config.endpointCId of
                    Just _ ->
                        ( model2, Double context appId1 (Just appId2) )

                    Nothing ->
                        ( model1, Double context appId1 Nothing )

            Apps.StaticContext context ->
                ( model1, Single context appId1 )


newWindow :
    Config msg
    -> WindowId
    -> DesktopApp
    -> Instance
    -> Model
    -> Model
newWindow config windowId desktopApp instance model =
    let
        sessionId =
            getSessionId config

        maybePosition =
            model
                |> getSession sessionId
                |> getFocusing
                |> Maybe.andThen (flip getWindow model)
                |> Maybe.map getPosition

        position =
            case maybePosition of
                Just { x, y } ->
                    Position (x + 32) (y + 32)

                Nothing ->
                    Position 32 (44 + 32)

        window =
            { position = position
            , size = (uncurry Size <| Apps.windowInitSize desktopApp)
            , maximized = False
            , instance = instance
            , originSessionId = sessionId
            }
    in
        insert windowId window model


cidToSessionId : CId -> SessionId
cidToSessionId cid =
    case cid of
        GatewayCId id ->
            "gateway_id::" ++ id

        EndpointCId ( nid, ip ) ->
            "endpoint_addr::" ++ nid ++ "::" ++ ip


getSessionId : Config msg -> SessionId
getSessionId =
    .activeServer >> Tuple.first >> cidToSessionId


getAppActiveServer : Config msg -> App -> Maybe ( CId, Server )
getAppActiveServer config app =
    let
        cid =
            getServerCId app
    in
        Maybe.map ((,) cid) <| Servers.get cid config.servers


getActiveContext : Config msg -> Context
getActiveContext config =
    if config.activeGateway == config.activeServer then
        Gateway
    else
        Endpoint


getWindowGateway : Config msg -> Model -> Window -> Maybe ( CId, Server )
getWindowGateway config model window =
    -- this function is kinda unsafe as some windows may not have a gateway
    let
        maybeAppId =
            case window.instance of
                Single Gateway appId ->
                    Just appId

                Single Endpoint _ ->
                    Nothing

                Double _ appId _ ->
                    Just appId
    in
        maybeAppId
            |> Maybe.andThen (flip getApp model)
            |> Maybe.andThen (getAppActiveServer config)


getAppActiveContext : Config msg -> Maybe Context -> AppContext -> Context
getAppActiveContext config maybeContext appContext =
    -- enforce app context rules but allow manipulating them when possible
    case appContext of
        Apps.DynamicContext ->
            case maybeContext of
                Just context ->
                    context

                Nothing ->
                    if config.activeServer == config.activeGateway then
                        Gateway
                    else
                        Endpoint

        Apps.StaticContext context ->
            context


isEndpointAvailable : Config msg -> Bool
isEndpointAvailable config =
    case config.endpointCId of
        Just _ ->
            True

        Nothing ->
            False
