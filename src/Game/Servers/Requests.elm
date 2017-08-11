module Game.Servers.Requests
    exposing
        ( Response(..)
        , ServerResponse(..)
        , receive
        , serverReceive
        )

import Game.Servers.Requests.Fetch as Fetch
import Game.Servers.Messages exposing (..)


type Response
    = FetchResponse Fetch.Response


type ServerResponse
    = NoResponse


receive : RequestMsg -> Response
receive response =
    case response of
        FetchRequest ( code, data ) ->
            data
                |> Fetch.receive code
                |> FetchResponse


serverReceive : ServerRequestMsg -> ServerResponse
serverReceive response =
    NoResponse
