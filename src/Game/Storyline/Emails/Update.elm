module Game.Storyline.Emails.Update exposing (update)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Models as Game
import Game.Notifications.Messages as Notifications
import Game.Notifications.Models as Notifications
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Messages exposing (..)
import Game.Storyline.Emails.Contents as Contents
import Events.Account.Story.NewEmail as StoryNewEmail


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Changed newModel ->
            onChanged newModel model

        HandleNewEmail data ->
            handleNewEmail game data model


onChanged : Model -> Model -> UpdateResponse
onChanged newModel oldModel =
    Update.fromModel newModel


handleNewEmail : Game.Model -> StoryNewEmail.Data -> Model -> UpdateResponse
handleNewEmail game { personId, message, responses, createNotification } model =
    let
        ( time, msg ) =
            message

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

        dispatch =
            case msg of
                Received content ->
                    content
                        |> Contents.toString
                        |> Notifications.NewEmail personId
                        |> Notifications.create
                        |> Notifications.Insert game.meta.lastTick
                        |> Dispatch.accountNotification

                Sent _ ->
                    Dispatch.none
    in
        ( model_, Cmd.none, dispatch )
