module Game.Storyline.Emails.Update exposing (update)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Models as Game
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Messages exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Changed newModel ->
            onChanged newModel model

        Receive personId messages responses ->
            onReceive personId messages responses model


onChanged : Model -> Model -> UpdateResponse
onChanged newModel oldModel =
    Update.fromModel newModel


onReceive : ID -> Messages -> Responses -> Model -> UpdateResponse
onReceive personId messages responses model =
    -- Called when Helix send us chat updates
    -- Creates person chat when it doesn't exists yet
    -- Insert/Update messages to person chat
    let
        apply person =
            let
                messages_ =
                    getMessages person
                        |> Dict.union messages

                person_ =
                    { person
                        | messages = messages_
                        , responses = responses
                    }
            in
                setPerson personId person_ model

        model_ =
            model
                |> getPerson personId
                |> Maybe.withDefault
                    { about = (personMetadata personId)
                    , messages = Dict.empty
                    , responses = []
                    }
                |> apply
    in
        Update.fromModel model_
