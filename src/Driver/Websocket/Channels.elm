module Driver.Websocket.Channels exposing (Channel(..), getAddress)

import Game.Account.Models as Account
import Game.Network.Types exposing (NIP)


type Channel
    = AccountChannel Account.ID
    | RequestsChannel
    | ServerChannel NIP


getAddress : Channel -> String
getAddress channel =
    case channel of
        AccountChannel id ->
            "account:" ++ id

        ServerChannel ( nid, ip ) ->
            "server:" ++ nid ++ "@" ++ ip

        RequestsChannel ->
            "requests"
