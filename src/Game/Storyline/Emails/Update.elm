module Game.Storyline.Emails.Update exposing (update)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Models as Game
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Messages exposing (..)
import Events.Account.Story.NewEmail as StoryNewEmail


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Changed newModel ->
            onChanged newModel model

        HandleNewEmail data ->
            handleNewEmail data model


onChanged : Model -> Model -> UpdateResponse
onChanged newModel oldModel =
    Update.fromModel newModel


handleNewEmail : StoryNewEmail.Data -> Model -> UpdateResponse
handleNewEmail ( personId, ( time, msg ), responses ) model =
    let
        apply person =
            let
                messages_ =
                    getMessages person
                        |> Dict.insert time msg

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
