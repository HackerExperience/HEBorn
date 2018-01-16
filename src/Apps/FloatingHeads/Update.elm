module Apps.FloatingHeads.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Storyline as Storyline
import Core.Dispatch.OS as OS
import Game.Data as Game
import Game.Storyline.Emails.Models as Emails exposing (ID)
import Game.Storyline.Emails.Contents exposing (Content)
import Game.Storyline.Emails.Contents.Messages as Contents
import Game.Storyline.Emails.Contents.Update as Contents
import Apps.FloatingHeads.Models exposing (Model, Mode(..))
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
