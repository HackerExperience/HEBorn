module Apps.FloatingHeads.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Meta.Types.Context exposing (Context)
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


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> FloatingHeads.Msg
    -> Model
    -> UpdateResponse msg
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


onContentMsg : Config msg -> Contents.Msg -> Model -> UpdateResponse msg
onContentMsg config msg model =
    let
        config_ =
            contentConfig config

        react =
            Contents.update config_ msg
    in
        ( model, React.map (ContentMsg >> config.toMsg) react )


onReply : Config msg -> Content -> Model -> UpdateResponse msg
onReply config content model =
    --let
    --    dispatch =
    --        content
    --            |> Storyline.ReplyEmail
    --            |> Dispatch.emails
    --in
    ( model, React.none )


handleSelectContact : Config msg -> ID -> Model -> UpdateResponse msg
handleSelectContact config contact model =
    let
        model_ =
            { model | activeContact = contact }
    in
        ( model_, React.none )


onToggleMode : Config msg -> Model -> UpdateResponse msg
onToggleMode config model =
    let
        model_ =
            case model.mode of
                Compact ->
                    { model | mode = Expanded }

                Expanded ->
                    { model | mode = Compact }
    in
        ( model_, React.none )


onClose : Config msg -> Model -> UpdateResponse msg
onClose config model =
    --let
    --    dispatch =
    --        Dispatch.os <| OS.CloseApp model.me
    --in
    ( model, React.none )


onLaunchApp : Config msg -> Context -> Params -> Model -> UpdateResponse msg
onLaunchApp config context params model =
    case params of
        OpenAtContact contact ->
            let
                model_ =
                    setActiveContact contact model
            in
                ( model_, React.none )
