module Game.Storyline.Emails.Models exposing (..)

import Time exposing (Time)
import Dict exposing (Dict)
import Game.Shared


type alias Model =
    Dict ID Person


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
    ID


type alias ID =
    Game.Shared.ID


getPerson : ID -> Model -> Maybe Person
getPerson =
    Dict.get


setPerson : ID -> Person -> Model -> Model
setPerson =
    Dict.insert


getMessages : Person -> Messages
getMessages =
    .messages


getAvailableResponses : Person -> Responses
getAvailableResponses =
    .responses


personMetadata : ID -> Maybe About
personMetadata who =
    case who of
        _ ->
            Nothing


initialModel : Model
initialModel =
    Dict.empty
