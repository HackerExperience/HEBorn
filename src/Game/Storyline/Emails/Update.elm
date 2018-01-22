module Game.Storyline.Emails.Update exposing (update)

import Dict
import Utils.React as React exposing (React)
import Game.Storyline.Emails.Config exposing (..)
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Messages exposing (..)
import Game.Storyline.Emails.Contents as Contents exposing (Content)
import Game.Storyline.Emails.Requests exposing (Response, receive)
import Game.Storyline.Emails.Requests.Reply as Reply
import Events.Account.Handlers.StoryEmailSent as StoryEmailSent
import Events.Account.Handlers.StoryEmailReplyUnlocked as StoryEmailReplyUnlocked


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        Changed newModel ->
            onChanged newModel model

        HandleReply content ->
            handleReply config content model

        HandleNewEmail data ->
            handleNewEmail config data model

        HandleReplyUnlocked data ->
            handleReplyUnlocked config data model

        Request data ->
            onRequest config (receive data) model


onChanged : Model -> Model -> UpdateResponse msg
onChanged newModel oldModel =
    ( newModel, React.none )


handleReply : Config msg -> Content -> Model -> UpdateResponse msg
handleReply config content model =
    let
        accountId =
            config.accountId

        contentId =
            Contents.toId content

        cmd =
            Reply.request accountId contentId config
                |> Cmd.map config.toMsg
                |> React.cmd
    in
        ( model, cmd )


handleNewEmail : Config msg -> StoryEmailSent.Data -> Model -> UpdateResponse msg
handleNewEmail config data model =
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
    in
        ( model_, React.none )


handleReplyUnlocked :
    Config msg
    -> StoryEmailReplyUnlocked.Data
    -> Model
    -> UpdateResponse msg
handleReplyUnlocked config { personId, replies } model =
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
        ( model_, React.none )



-- requests


onRequest : Config msg -> Maybe Response -> Model -> UpdateResponse msg
onRequest config response model =
    case response of
        Just response ->
            updateRequest config response model

        Nothing ->
            ( model, React.none )


updateRequest : Config msg -> Response -> Model -> UpdateResponse msg
updateRequest config response model =
    ( model, React.none )
