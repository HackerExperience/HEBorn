module Game.Storyline.Models exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)
import Game.Storyline.Shared exposing (..)
import Game.Storyline.StepActions.Shared exposing (Action)


type alias Model =
    Dict ContactID Contact


type alias ContactID =
    String


type alias Contact =
    { availableReplies : Reply
    , pastEmails : Dict Time SendedEmail
    , step : Maybe ( Step, List Action )
    , objective : Maybe Objective
    , quest : Maybe Quest
    , about : About
    }


initialModel : Model
initialModel =
    Dict.empty


initalAbout : ContactID -> About
initalAbout who =
    case who of
        "friend" ->
            About "Friend" "friendpic.jpg"

        _ ->
            About "Unkown Contact" "unknown.jpg"
