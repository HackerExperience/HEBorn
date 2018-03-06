module Widgets.TaskList.Update exposing (update)

import Utils.React as React exposing (React)
import Widgets.TaskList.Config exposing (Config)
import Widgets.TaskList.Messages exposing (..)
import Widgets.TaskList.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        ToogleCheck i ->
            model
                |> toggleCheck i
                |> React.update

        Update i value_ ->
            model
                |> set i value_
                |> React.update

        Insert value_ ->
            model
                |> insert value_
                |> React.update

        Remove i ->
            model
                |> remove i
                |> React.update
