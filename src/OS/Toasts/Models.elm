module OS.Toasts.Models exposing (..)

import Dict exposing (Dict)
import Game.Notifications.Source exposing (Source)
import Game.Notifications.Models as Notifications


type alias Model =
    Dict Int Toast


type alias Toast =
    { notification : Notifications.Content
    , parent : Maybe Source
    , state : State
    }


type State
    = Alive
    | Fading
    | Garbage


initialModel : Model
initialModel =
    Dict.empty


insert : Toast -> Model -> ( Int, Model )
insert new src =
    src
        |> Dict.keys
        |> List.reverse
        |> List.head
        |> Maybe.withDefault 0
        |> flip (+) 1
        |> \k ->
            ( k, Dict.insert k new src )


get : Int -> Model -> Maybe Toast
get =
    Dict.get


replace : Int -> Toast -> Model -> Model
replace =
    Dict.insert


remove : Int -> Model -> Model
remove =
    Dict.remove


setState : State -> Toast -> Toast
setState state toast =
    { toast | state = state }
