module Game.Storyline.Emails.Update exposing (update)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Notifications as Notifications
import Utils.Update as Update
import Game.Models as Game
import Game.Notifications.Messages as Notifications
import Game.Notifications.Models as Notifications
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Messages exposing (..)
import Game.Storyline.Emails.Contents as Contents exposing (Content)
import Game.Storyline.Emails.Requests exposing (Response, receive)
import Game.Storyline.Emails.Requests.Reply as Reply
import Events.Account.Story.NewEmail as StoryNewEmail
import Events.Account.Story.ReplyUnlocked as StoryReplyUnlocked


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Changed newModel ->
            onChanged newModel model

        HandleReply content ->
            handleReply game content model

        HandleNewEmail data ->
            handleNewEmail game data model

        HandleReplyUnlocked data ->
            handleReplyUnlocked game data model

        Request data ->
            onRequest game (receive data) model


onChanged : Model -> Model -> UpdateResponse
onChanged newModel oldModel =
    Update.fromModel newModel


handleReply : Game.Model -> Content -> Model -> UpdateResponse
handleReply game content model =
    let
        accountId =
            Game.getAccount game
                |> .id

        contentId =
            Contents.toId content

        cmd =
            Reply.request accountId contentId game
    in
        ( model, cmd, Dispatch.none )


handleNewEmail : Game.Model -> StoryNewEmail.Data -> Model -> UpdateResponse
handleNewEmail game data model =
    let
        { personId, messageNode, replies, createNotification } =
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
                    , replies =
                        replies
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
                            , replies = replies
                        }

        model_ =
            setPerson personId person_ model

        dispatch =
            personId
                |> Notifications.NewEmail
                |> Notifications.NotifyAccount (Just time)
                |> Dispatch.notifications
    in
        ( model_, Cmd.none, dispatch )


handleReplyUnlocked :
    Game.Model
    -> StoryReplyUnlocked.Data
    -> Model
    -> UpdateResponse
handleReplyUnlocked game { personId, replies } model =
    let
        person_ =
            case getPerson personId model of
                Nothing ->
                    { about =
                        personMetadata personId
                    , messages =
                        Dict.empty
                    , replies =
                        replies
                    }

                Just person ->
                    let
                        replies_ =
                            person
                                |> getAvailableReplies
                                |> (++) replies
                    in
                        { person
                            | replies = replies
                        }

        model_ =
            setPerson personId person_ model
    in
        ( model_, Cmd.none, Dispatch.none )



-- requests


onRequest : Game.Model -> Maybe Response -> Model -> UpdateResponse
onRequest game response model =
    case response of
        Just response ->
            updateRequest game response model

        Nothing ->
            Update.fromModel model


updateRequest : Game.Model -> Response -> Model -> UpdateResponse
updateRequest game response model =
    Update.fromModel model
