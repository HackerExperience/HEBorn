module Game.Servers.Logs.Requests
    exposing
        ( Response(..)
        , LogResponse(..)
        , receive
        , logReceive
        )

import Game.Servers.Logs.Messages exposing (..)


type Response
    = Response


type LogResponse
    = LogResponse


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        _ ->
            Nothing


logReceive : LogRequestMsg -> Maybe LogResponse
logReceive response =
    Nothing
