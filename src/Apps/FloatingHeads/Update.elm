module Apps.FloatingHeads.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Storyline.Shared exposing (ContactId, Reply)
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

        LaunchApp params ->
            onLaunchApp config params model


onReply : Config msg -> Reply -> Model -> UpdateResponse msg
onReply config content model =
    content
        |> config.onReply model.activeContact
        |> React.msg
        |> (,) model


handleSelectContact : Config msg -> ContactId -> Model -> UpdateResponse msg
handleSelectContact config contact model =
    React.update { model | activeContact = contact }


onToggleMode : Config msg -> Model -> UpdateResponse msg
onToggleMode config model =
    let
        mode_ =
            case model.mode of
                Compact ->
                    Expanded

                Expanded ->
                    Compact
    in
        React.update { model | mode = mode_ }


onClose : Config msg -> Model -> UpdateResponse msg
onClose config model =
    config.onCloseApp
        |> React.msg
        |> (,) model


onLaunchApp : Config msg -> Params -> Model -> UpdateResponse msg
onLaunchApp config params model =
    case params of
        OpenAtContact contact ->
            React.update <| setActiveContact contact model
