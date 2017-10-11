module Driver.Websocket.Channels exposing (..)

import Game.Account.Models as Account
import Game.Servers.Shared as Servers


type Channel
    = AccountChannel Account.ID
    | RequestsChannel
    | ServerChannel Servers.ID


getAddress : Channel -> String
getAddress channel =
    case channel of
        AccountChannel id ->
            "account:" ++ id

        ServerChannel ( nid, ip ) ->
            "server:" ++ nid ++ "@" ++ ip

        RequestsChannel ->
            "requests"
