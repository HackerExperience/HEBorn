module Game.BackFeed.Requests
    exposing
        ( Response(..)
        , BackLogResponse(..)
        , receive
        , logReceive
        )

import Game.BackFeed.Messages exposing (..)


type Response
    = Response


type BackLogResponse
    = BackFeedResponse


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        _ ->
            Nothing


logReceive : BackLogRequestMsg -> Maybe BackLogResponse
logReceive response =
    Nothing
