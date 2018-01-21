module Apps.FloatingHeads.Update exposing (update)

import Utils.Update as Update
import Utils.React as React exposing (React)
import Game.Meta.Types.Context exposing (Context)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Storyline as Storyline
import Core.Dispatch.OS as OS
import Game.Data as Game
import Game.Storyline.Emails.Models as Emails exposing (ID)
import Game.Storyline.Emails.Contents exposing (Content)
import Game.Storyline.Emails.Contents.Messages as Contents
import Game.Storyline.Emails.Contents.Update as Contents
import Apps.FloatingHeads.Models exposing (..)
import Apps.FloatingHeads.Messages as FloatingHeads exposing (Msg(..))
import Utils.Html.Events exposing (onClickMe, onKeyDown)
import Apps.Reference exposing (Reference)


type alias UpdateResponse =
    ( Model, Cmd FloatingHeads.Msg, Dispatch )


update :
    Game.Data
    -> FloatingHeads.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        ContentMsg msg ->
            onContentMsg data msg model

        Reply content ->
            onReply data content model

        HandleSelectContact contact ->
            handleSelectContact data contact model

        ToggleMode ->
            onToggleMode data model

        Close ->
            onClose data model

        LaunchApp context params ->
            onLaunchApp data context params model


onContentMsg : Game.Data -> Contents.Msg -> Model -> UpdateResponse
onContentMsg data msg model =
    let
        ( cmd, dispatch ) =
            Contents.update data msg

        cmd_ =
            Cmd.map ContentMsg cmd
    in
        ( model, cmd_, dispatch )


onReply : Game.Data -> Content -> Model -> UpdateResponse
onReply data content model =
    let
        dispatch =
            content
                |> Storyline.ReplyEmail
                |> Dispatch.emails
    in
        ( model, Cmd.none, dispatch )


handleSelectContact : Game.Data -> ID -> Model -> UpdateResponse
handleSelectContact data contact model =
    let
        model_ =
            { model | activeContact = contact }
    in
        Update.fromModel model_


onToggleMode : Game.Data -> Model -> UpdateResponse
onToggleMode data model =
    let
        model_ =
            case model.mode of
                Compact ->
                    { model | mode = Expanded }

                Expanded ->
                    { model | mode = Compact }
    in
        Update.fromModel model_


onClose : Game.Data -> Model -> UpdateResponse
onClose data model =
    let
        dispatch =
            Dispatch.os <| OS.CloseApp model.me
    in
        ( model, Cmd.none, dispatch )


onLaunchApp : Game.Data -> Context -> Params -> Model -> UpdateResponse
onLaunchApp data context params model =
    case params of
        OpenAtContact contact ->
            Update.fromModel <| setActiveContact contact model
