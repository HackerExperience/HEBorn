module Game.Storyline.Models exposing (..)

import Dict exposing (Dict)
import Utils.List as List
import Utils.Maybe as Maybe
import Game.Storyline.Shared exposing (..)
import Game.Storyline.StepActions.Shared exposing (Action)


type alias Model =
    Dict ContactId Contact


type alias Contact =
    { availableReplies : List Reply
    , pastEmails : PastEmails
    , step : Maybe ( Step, List Action )
    , objective : Maybe Objective
    , quest : Maybe Quest
    , about : About
    }


initialModel : Model
initialModel =
    Dict.empty


initialAbout : ContactId -> About
initialAbout who =
    case who of
        "friend" ->
            About "Friend" "images/avatar.jpg"

        _ ->
            About "Unkown Contact" "images/avatar.jpg"


getPastEmails : Contact -> PastEmails
getPastEmails =
    (.pastEmails)


getContact : ContactId -> Model -> Maybe Contact
getContact =
    Dict.get


setContact : ContactId -> Contact -> Model -> Model
setContact =
    Dict.insert


getAvailableReplies : Contact -> List Reply
getAvailableReplies =
    (.availableReplies)


getActions : Model -> List Action
getActions model =
    model
        |> Dict.foldl acuAction []
        |> List.uniqueBy toString


noQuests : Model -> Bool
noQuests model =
    model
        |> Dict.filter
            (\_ -> .step >> Maybe.isJust)
        |> Dict.isEmpty


isAnyoneInStep : Step -> Model -> Bool
isAnyoneInStep step model =
    let
        check _ contact acu =
            acu || (getStep contact == Just step)
    in
        Dict.foldr check False model



-- about contact


getNick : Contact -> String
getNick =
    .about >> .nick


getAvatar : Contact -> String
getAvatar =
    .about >> .picture


getStep : Contact -> Maybe Step
getStep { step } =
    Maybe.map Tuple.first step



-- helper


acuAction : ContactId -> Contact -> List Action -> List Action
acuAction _ { step } acu =
    case step of
        Just ( _, actions ) ->
            acu ++ actions

        Nothing ->
            acu
