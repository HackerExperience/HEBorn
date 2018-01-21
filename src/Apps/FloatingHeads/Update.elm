module Apps.FloatingHeads.Update exposing (update)

import Utils.Update as Update
import Game.Meta.Types.Context exposing (Context)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Storyline as Storyline
import Core.Dispatch.OS as OS
import Game.Data as Game
import Game.Storyline.Emails.Models as Emails exposing (ID)
import Game.Storyline.Emails.Contents exposing (Content)
import Game.Storyline.Emails.Contents.Messages as Contents
import Game.Storyline.Emails.Contents.Update as Contents
import Apps.FloatingHeads.Config exposing (..)
import Apps.FloatingHeads.Models exposing (..)
import Apps.FloatingHeads.Messages as FloatingHeads exposing (Msg(..))
import Utils.Html.Events exposing (onClickMe, onKeyDown)
import Apps.Reference exposing (Reference)


type alias UpdateResponse =
    ( Model, Cmd FloatingHeads.Msg, Dispatch )


update :
    Config msg
    -> FloatingHeads.Msg
    -> Model
    -> UpdateResponse
update config msg model =
    case msg of
        ContentMsg msg ->
            onContentMsg config msg model

        Reply content ->
            onReply config content model

        HandleSelectContact contact ->
            handleSelectContact config contact model

        ToggleMode ->
            onToggleMode config model

        Close ->
            onClose config model

        LaunchApp context params ->
            onLaunchApp config context params model


onContentMsg : Config msg -> Contents.Msg -> Model -> UpdateResponse
onContentMsg config msg model =
    let
        config_ =
            contentConfig config

        ( cmd, dispatch ) =
            Contents.update config_ msg

        cmd_ =
            Cmd.map ContentMsg cmd
    in
        ( model, cmd_, dispatch )


onReply : Config msg -> Content -> Model -> UpdateResponse
onReply config content model =
    let
        dispatch =
            content
                |> Storyline.ReplyEmail
                |> Dispatch.emails
    in
        ( model, Cmd.none, dispatch )


handleSelectContact : Config msg -> ID -> Model -> UpdateResponse
handleSelectContact config contact model =
    let
        model_ =
            { model | activeContact = contact }
    in
        Update.fromModel model_


onToggleMode : Config msg -> Model -> UpdateResponse
onToggleMode config model =
    let
        model_ =
            case model.mode of
                Compact ->
                    { model | mode = Expanded }

                Expanded ->
                    { model | mode = Compact }
    in
        Update.fromModel model_


onClose : Config msg -> Model -> UpdateResponse
onClose config model =
    let
        dispatch =
            Dispatch.os <| OS.CloseApp model.me
    in
        ( model, Cmd.none, dispatch )


onLaunchApp : Config msg -> Context -> Params -> Model -> UpdateResponse
onLaunchApp config context params model =
    case params of
        OpenAtContact contact ->
            Update.fromModel <| setActiveContact contact model
