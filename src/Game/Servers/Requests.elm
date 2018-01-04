module Game.Servers.Requests
    exposing
        ( Response(..)
        , ServerResponse(..)
        , receive
        , serverReceive
        )

import Time exposing (Time)
import Game.Servers.Requests.Resync as Resync
import Game.Servers.Messages
    exposing
        ( RequestMsg(..)
        , ServerRequestMsg(..)
        )


type Response
    = ResyncServer Resync.Response


type ServerResponse
    = ServerResponse


receive : Time -> RequestMsg -> Maybe Response
receive now response =
    case response of
        ResyncRequest maybeServerUid id ( code, data ) ->
            Maybe.map ResyncServer <|
                Resync.receive now maybeServerUid id code data


serverReceive : ServerRequestMsg -> Maybe ServerResponse
serverReceive response =
    case response of
        NoOp ->
            Nothing
