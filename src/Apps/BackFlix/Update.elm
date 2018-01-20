module Apps.BackFlix.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.BackFlix.Models exposing (..)
import Apps.BackFlix.Messages as BackFlix exposing (Msg(..))


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Data
    -> BackFlix.Msg
    -> Model
    -> ( Model, Cmd BackFlix.Msg, Dispatch )
update data msg model =
    case msg of
        UpdateTextFilter filter ->
            onUpdateFilter data filter model

        GoTab tab ->
            onGoTabs data tab model


onGoTabs : Game.Data -> MainTab -> Model -> UpdateResponse
onGoTabs data tab model =
    let
        model_ =
            { model | selected = tab }
    in
        ( model_, Cmd.none, Dispatch.none )


onUpdateFilter : Game.Data -> String -> Model -> UpdateResponse
onUpdateFilter data filter model =
    Update.fromModel model
