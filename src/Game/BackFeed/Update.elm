module Game.BackFeed.Update exposing (update)

import Utils.Update as Update
import Game.Models as Game
import Game.BackFeed.Models exposing (..)
import Game.BackFeed.Messages exposing (..)
import Game.BackFeed.Requests exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias WebLogUpdateResponse =
    ( BackLog, Cmd BackLogMsg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        HandleCreate log ->
            onHandleCreate log model

        _ ->
            Update.fromModel model


onHandleCreate : BackLog -> Model -> UpdateResponse
onHandleCreate log model =
    Update.fromModel (insertLog log model)
