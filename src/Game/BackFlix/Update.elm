module Game.BackFlix.Update exposing (update)

import Utils.React as React exposing (React)
import Game.BackFlix.Models exposing (..)
import Game.BackFlix.Messages exposing (..)
import Game.BackFlix.Config exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update _ msg model =
    case msg of
        HandleCreate log ->
            onHandleCreate log model

        _ ->
            React.update model


onHandleCreate : Log -> Model -> UpdateResponse msg
onHandleCreate log model =
    model
        |> insert log
        |> React.update
