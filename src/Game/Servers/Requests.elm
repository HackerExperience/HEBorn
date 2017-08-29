module Game.Servers.Requests
    exposing
        ( Response(..)
        , ServerResponse(..)
        , receive
        , serverReceive
        )

import Game.Servers.Requests.Bootstrap as Bootstrap
import Game.Servers.Messages
    exposing
        ( RequestMsg(BootstrapRequest)
        , ServerRequestMsg
        )


type Response
    = BootstrapServer Bootstrap.Response


type ServerResponse
    = Server


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        BootstrapRequest ( code, data ) ->
            data
                |> Bootstrap.receive code
                |> Maybe.map BootstrapServer


serverReceive : ServerRequestMsg -> Maybe ServerResponse
serverReceive response =
    Nothing
