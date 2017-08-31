module Game.Servers.Requests
    exposing
        ( Response(..)
        , ServerResponse(..)
        , receive
        , serverReceive
        )

import Game.Servers.Requests.Bootstrap as Bootstrap
import Game.Servers.Requests.Bruteforce as Bruteforce
import Game.Servers.Messages
    exposing
        ( RequestMsg(..)
        , ServerRequestMsg
        )


type Response
    = BootstrapServer Bootstrap.Response
    | Bruteforce Bruteforce.Response


type ServerResponse
    = Server


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        BootstrapRequest ( code, data ) ->
            Maybe.map BootstrapServer <| Bootstrap.receive code data

        BruteforceRequest ( code, data ) ->
            Maybe.map Bruteforce <| Bruteforce.receive code data


serverReceive : ServerRequestMsg -> Maybe ServerResponse
serverReceive response =
    Nothing
