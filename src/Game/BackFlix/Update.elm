module Game.BackFlix.Update exposing (update)

import Utils.Update as Update
import Game.BackFlix.Models exposing (..)
import Game.BackFlix.Messages exposing (..)
import Game.BackFlix.Config exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update _ msg model =
    case msg of
        HandleCreate log ->
            onHandleCreate log model

        _ ->
            Update.fromModel model


onHandleCreate : Log -> Model -> UpdateResponse msg
onHandleCreate log model =
    model
        |> insertLog log
        |> Update.fromModel
