module Game.Servers.Logs.Requests
    exposing
        ( Response(..)
        , LogResponse(..)
        , receive
        , logReceive
        )

import Game.Servers.Logs.Requests.Index as Index
import Game.Servers.Logs.Messages exposing (..)


type Response
    = IndexResponse Index.Response


type LogResponse
    = NoResponse


receive : RequestMsg -> Response
receive response =
    case response of
        IndexRequest ( code, data ) ->
            data
                |> Index.receive code
                |> IndexResponse


logReceive : LogRequestMsg -> LogResponse
logReceive response =
    case response of
        _ ->
            NoResponse
