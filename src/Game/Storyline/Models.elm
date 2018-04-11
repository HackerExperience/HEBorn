module Game.Storyline.Models exposing (..)

import Dict exposing (Dict)
import Utils.List as List
import Utils.Maybe as Maybe
import Game.Storyline.Shared exposing (..)
import Game.Storyline.StepActions.Shared exposing (Action)


type alias Model =
    { contacts : Contacts
    , highestCheckpoint : Checkpoint
    }


type alias Contacts =
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
    { contacts = Dict.empty
    , highestCheckpoint = checkpoint Nothing Nothing Nothing
    }


fromContacts : Contacts -> Model
fromContacts contacts =
    let
        check _ contact acu =
            let
                thisCp =
                    checkpoint
                        (getQuest contact)
                        (getStep contact)
                        (getLastReply contact)
            in
                if (thisCp >= acu) then
                    thisCp
                else
                    acu
    in
        { contacts = contacts
        , highestCheckpoint =
            Dict.foldl check
                (checkpoint Nothing Nothing Nothing)
                contacts
        }


getCheckpoint : Model -> Checkpoint
getCheckpoint { highestCheckpoint } =
    highestCheckpoint


setCheckpoint : Checkpoint -> Model -> Model
setCheckpoint checkpoint model =
    { model | highestCheckpoint = checkpoint }


getContacts : Model -> Contacts
getContacts { contacts } =
    contacts


setContacts : Contacts -> Model -> Model
setContacts contacts model =
    { model | contacts = contacts }


getActions : Model -> List Action
getActions model =
    model
        |> getContacts
        |> Dict.foldl acuAction []
        |> List.uniqueBy toString


noQuests : Model -> Bool
noQuests model =
    model
        |> getContacts
        |> Dict.filter
            (\_ -> .step >> Maybe.isJust)
        |> Dict.isEmpty


isAnyoneInStep : Step -> Model -> Bool
isAnyoneInStep step model =
    let
        check _ contact acu =
            acu || (getStep contact == Just step)
    in
        model
            |> getContacts
            |> Dict.foldr check False


getContact : ContactId -> Model -> Maybe Contact
getContact cId model =
    model
        |> getContacts
        |> Dict.get cId


setContact : ContactId -> Contact -> Model -> Model
setContact cId val model =
    model
        |> getContacts
        |> Dict.insert cId val
        |> flip setContacts model



-- about contact


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


getAvailableReplies : Contact -> List Reply
getAvailableReplies =
    (.availableReplies)


getNick : Contact -> String
getNick =
    .about >> .nick


getAvatar : Contact -> String
getAvatar =
    .about >> .picture


getStep : Contact -> Maybe Step
getStep { step } =
    Maybe.map Tuple.first step


getQuest : Contact -> Maybe Quest
getQuest { quest } =
    quest


getLastReply : Contact -> Maybe Reply
getLastReply { pastEmails } =
    pastEmails
        |> Dict.values
        |> List.foldl (Just >> always) Nothing
        |> Maybe.map emailToReply



-- helper


acuAction : ContactId -> Contact -> List Action -> List Action
acuAction _ { step } acu =
    case step of
        Just ( _, actions ) ->
            acu ++ actions

        Nothing ->
            acu
