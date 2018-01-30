module OS.WindowManager.Helpers exposing (..)

import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared as Servers exposing (CId(..))
import OS.WindowManager.Config exposing (..)
import OS.WindowManager.Models exposing (..)
import OS.WindowManager.Shared exposing (..)


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
