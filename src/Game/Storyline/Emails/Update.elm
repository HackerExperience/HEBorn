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
import Events.Account.Story.ReplyUnlocked as StoryReplyUnlocked


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Changed newModel ->
            onChanged newModel model

        HandleNewEmail data ->
            handleNewEmail game data model

        HandleReplyUnlocked data ->
            handleReplyUnlocked game data model


onChanged : Model -> Model -> UpdateResponse
onChanged newModel oldModel =
    Update.fromModel newModel


handleNewEmail : Game.Model -> StoryNewEmail.Data -> Model -> UpdateResponse
handleNewEmail game data model =
    let
        { personId, messageNode, responses, createNotification } =
            data

        ( time, msg ) =
            messageNode

        person_ =
            case getPerson personId model of
                Nothing ->
                    { about =
                        personMetadata personId
                    , messages =
                        messageNode
                            |> List.singleton
                            |> Dict.fromList
                    , responses =
                        responses
                    }

                Just person ->
                    let
                        messages_ =
                            person
                                |> getMessages
                                |> Dict.insert time msg
                    in
                        { person
                            | messages = messages_
                            , responses = responses
                        }

        model_ =
            setPerson personId person_ model

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


handleReplyUnlocked :
    Game.Model
    -> StoryReplyUnlocked.Data
    -> Model
    -> UpdateResponse
handleReplyUnlocked game { personId, responses } model =
    let
        person_ =
            case getPerson personId model of
                Nothing ->
                    { about =
                        personMetadata personId
                    , messages =
                        Dict.empty
                    , responses =
                        responses
                    }

                Just person ->
                    let
                        responses_ =
                            person
                                |> getAvailableResponses
                                |> (++) responses
                    in
                        { person
                            | responses = responses
                        }

        model_ =
            setPerson personId person_ model
    in
        ( model_, Cmd.none, Dispatch.none )
