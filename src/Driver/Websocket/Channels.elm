module Driver.Websocket.Channels exposing (..)

import Game.Account.Models as Account
import Game.Servers.Shared as Servers


type Channel
    = AccountChannel Account.ID
    | ServerChannel Servers.CId


getAddress : Channel -> String
getAddress channel =
    case channel of
        AccountChannel id ->
            "account:" ++ id

        ServerChannel cid ->
            case cid of
                Servers.GatewayCId id ->
                    "server:" ++ id

                Servers.EndpointCId ( id, ip ) ->
                    "server:" ++ id ++ "@" ++ ip
