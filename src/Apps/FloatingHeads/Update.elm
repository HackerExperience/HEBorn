module Apps.FloatingHeads.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Meta.Types.Context exposing (Context)
import Game.Storyline.Emails.Models as Emails exposing (ID)
import Game.Storyline.Emails.Contents exposing (Content)
import Apps.FloatingHeads.Config exposing (..)
import Apps.FloatingHeads.Models exposing (..)
import Apps.FloatingHeads.Messages as FloatingHeads exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> FloatingHeads.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
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


onReply : Config msg -> Content -> Model -> UpdateResponse msg
onReply { onReplyEmail } content model =
    content
        |> onReplyEmail
        |> React.msg
        |> (,) model


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
        mode_ =
            case model.mode of
                Compact ->
                    Expanded

                Expanded ->
                    Compact

        model_ =
            { model | mode = mode_ }
    in
        ( model_, React.none )


onClose : Config msg -> Model -> UpdateResponse msg
onClose { onCloseApp } model =
    onCloseApp
        |> React.msg
        |> (,) model


onLaunchApp : Config msg -> Context -> Params -> Model -> UpdateResponse msg
onLaunchApp config context params model =
    case params of
        OpenAtContact contact ->
            let
                model_ =
                    setActiveContact contact model
            in
                ( model_, React.none )
