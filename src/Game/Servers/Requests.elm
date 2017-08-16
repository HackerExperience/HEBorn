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
    = Fetch Fetch.Response


type ServerResponse
    = Server


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        FetchRequest ( code, data ) ->
            data
                |> Fetch.receive code
                |> Maybe.map Fetch


serverReceive : ServerRequestMsg -> Maybe ServerResponse
serverReceive response =
    Nothing
