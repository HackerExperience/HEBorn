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
        ( RequestMsg(..)
        , ServerRequestMsg(..)
        )


type Response
    = BootstrapServer Bootstrap.Response


type ServerResponse
    = ServerResponse


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        BootstrapRequest ( code, data ) ->
            Maybe.map BootstrapServer <| Bootstrap.receive code data



serverReceive : ServerRequestMsg -> Maybe ServerResponse
serverReceive response =
    case response of
        NoOp ->
            Nothing