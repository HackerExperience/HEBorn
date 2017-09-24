module OS.Toasts.Models exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)
import Game.Notifications.Models as Notifications


type alias Model =
    Dict Int Toast


type alias Toast =
    { notification : Notifications.Content
    , parent : Maybe Parent
    , state : State
    }


type alias Parent =
    ( Source, Notifications.ID )


type State
    = Alive
    | Fading
    | Garbage


type Source
    = Server ID
    | Account
    | Chat


type alias ID =
    String


dummy : Toast
dummy =
    Toast (Notifications.Simple "Hi" "Hello") Nothing Alive


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
