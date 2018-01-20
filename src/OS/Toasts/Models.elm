module OS.Toasts.Models exposing (..)

import Dict exposing (Dict)
import Game.Servers.Shared exposing (CId)
import Game.Account.Notifications.Shared as AccountNotifications
import Game.Servers.Notifications.Shared as ServersNotifications


type alias Model =
    Dict Int Toast


type alias Toast =
    { notification : Content
    , state : State
    }


type Content
    = Server CId ServersNotifications.Content
    | Account AccountNotifications.Content


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
