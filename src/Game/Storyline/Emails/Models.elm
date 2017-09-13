module Game.Storyline.Emails.Models exposing (..)

import Time exposing (Time)
import Dict exposing (Dict)


type alias Model =
    Dict PersonID Person


type alias Email =
    String


type alias Person =
    { about : Maybe About
    , messages : Messages
    , responses : Responses
    }


type alias About =
    { email : Email
    , name : String
    , picture : String
    }


type Message
    = Sended PhraseID
    | Received PhraseID


type alias Messages =
    Dict Time Message


type alias Responses =
    List PhraseID


type alias PhraseID =
    String


type alias PersonID =
    String


type alias ReceiveData =
    ( PersonID, Messages, Responses )


getPerson : PersonID -> Model -> Maybe Person
getPerson =
    Dict.get


setPerson : PersonID -> Person -> Model -> Model
setPerson =
    Dict.insert


getMessages : Person -> Messages
getMessages =
    .messages


getAvailableResponses : Person -> Responses
getAvailableResponses =
    .responses


personMetadata : PersonID -> Maybe About
personMetadata who =
    case who of
        _ ->
            Nothing


initialModel : Model
initialModel =
    Dict.empty
