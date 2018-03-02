module Widgets.TaskList.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (value, type_, checked)
import Html.Events exposing (onClick, onInput)
import Widgets.TaskList.Config exposing (Config)
import Widgets.TaskList.Messages exposing (..)
import Widgets.TaskList.Models exposing (..)


view : Config msg -> Model -> Html msg
view config { entries } =
    entries
        |> List.foldr
            (entry config)
            ( List.length entries - 1, [] )
        |> Tuple.second
        |> ul []


entry :
    Config msg
    -> ( Bool, String )
    -> ( Int, List (Html msg) )
    -> ( Int, List (Html msg) )
entry { toMsg } ( active, value_ ) ( count, acu ) =
    li []
        [ input
            [ onClick <| toMsg <| ToogleCheck count
            , type_ "checkbox"
            , checked active
            ]
            []
        , input
            [ onInput (toMsg << Update count)
            , value value_
            ]
            []
        ]
        |> flip (::) acu
        |> (,) (count - 1)
