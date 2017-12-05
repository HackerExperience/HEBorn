module Game.LogStream.Requests
    exposing
        ( Response(..)
        , LogResponse(..)
        , receive
        , logReceive
        )

import Game.LogStream.Messages exposing (..)


type Response
    = Response


type LogResponse
    = LogStreamResponse


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        _ ->
            Nothing


logReceive : LogRequestMsg -> Maybe LogResponse
logReceive response =
    Nothing
