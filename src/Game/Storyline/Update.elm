module Game.Storyline.Update exposing (update)

import Dict
import Time exposing (Time)
import Utils.React as React exposing (React)
import Events.Account.Handlers.StoryEmailSent as StoryEmailSent
import Events.Account.Handlers.StoryEmailReplyUnlocked as StoryEmailReplyUnlocked
import Game.Storyline.Requests.Reply as ReplyRequest exposing (replyRequest)
import Game.Storyline.Config exposing (..)
import Game.Storyline.Messages exposing (..)
import Game.Storyline.Models exposing (..)
import Game.Storyline.Shared exposing (Reply, PastEmail(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleReply contactId reply ->
            handleReply config contactId reply model

        HandleNewEmail data ->
            handleNewEmail config data model

        HandleReplyUnlocked data ->
            handleReplyUnlocked config data model

        HandleReplySent { timestamp, reply, contactId } ->
            handleReplySent config timestamp contactId reply model

        HandleActionDone _ ->
            -- TODO: Need help
            ( model, React.none )

        HandleStepProceeded _ ->
            -- TODO: Need help
            ( model, React.none )

        ReplyRequest data ->
            onReplyRequest config data model


handleReply : Config msg -> String -> Reply -> Model -> UpdateResponse msg
handleReply config contactId reply model =
    config
        |> replyRequest contactId reply config.accountId reply
        |> Cmd.map (ReplyRequest >> config.toMsg)
        |> React.cmd
        |> (,) model


handleNewEmail : Config msg -> StoryEmailSent.Data -> Model -> UpdateResponse msg
handleNewEmail config data model =
    let
        { contactId, messageNode, replies, createNotification } =
            data

        person_ =
            case getContact contactId model of
                Nothing ->
                    { pastEmails =
                        messageNode
                            |> List.singleton
                            |> Dict.fromList
                    , availableReplies =
                        replies
                    , step = Nothing
                    , objective = Nothing
                    , quest = Nothing
                    , about = initialAbout contactId
                    }

                Just person ->
                    let
                        messages_ =
                            person
                                |> getPastEmails
                                |> (uncurry Dict.insert messageNode)
                    in
                        { person
                            | pastEmails = messages_
                            , availableReplies = replies
                        }

        model_ =
            setContact contactId person_ model
    in
        ( model_, React.none )


handleReplyUnlocked :
    Config msg
    -> StoryEmailReplyUnlocked.Data
    -> Model
    -> UpdateResponse msg
handleReplyUnlocked config { contactId, replies } model =
    let
        person_ =
            case getContact contactId model of
                Nothing ->
                    { pastEmails =
                        Dict.empty
                    , availableReplies =
                        replies
                    , step = Nothing
                    , objective = Nothing
                    , quest = Nothing
                    , about = initialAbout contactId
                    }

                Just person ->
                    let
                        replies_ =
                            person
                                |> getAvailableReplies
                                |> (++) replies
                    in
                        { person
                            | availableReplies = replies
                        }

        model_ =
            setContact contactId person_ model
    in
        ( model_, React.none )


handleReplySent :
    Config msg
    -> Time
    -> String
    -> Reply
    -> Model
    -> UpdateResponse msg
handleReplySent _ when contactId reply model =
    let
        person_ =
            case getContact contactId model of
                Nothing ->
                    { pastEmails =
                        ( when, FromPlayer reply )
                            |> List.singleton
                            |> Dict.fromList
                    , availableReplies =
                        []
                    , step = Nothing
                    , objective = Nothing
                    , quest = Nothing
                    , about = initialAbout contactId
                    }

                Just contact ->
                    { contact
                        | pastEmails =
                            contact
                                |> getPastEmails
                                |> Dict.insert
                                    when
                                    (FromPlayer reply)
                    }

        model_ =
            setContact contactId person_ model
    in
        ( model_, React.none )


onReplyRequest : Config msg -> ReplyRequest.Data -> Model -> UpdateResponse msg
onReplyRequest config data model =
    ( model, React.none )
