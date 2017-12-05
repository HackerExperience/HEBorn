module Game.LogStream.Update exposing (update)

import Utils.Update as Update
import Game.Models as Game
import Game.LogStream.Models exposing (..)
import Game.LogStream.Messages exposing (..)
import Game.LogStream.Requests exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias WebLogUpdateResponse =
    ( Log, Cmd LogMsg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        HandleCreate log ->
            onHandleCreate log model

        _ ->
            Update.fromModel model


onHandleCreate : Log -> Model -> UpdateResponse
onHandleCreate log model =
    Update.fromModel (insertLog log model)
