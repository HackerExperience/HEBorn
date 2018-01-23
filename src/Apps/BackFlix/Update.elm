module Apps.BackFlix.Update exposing (update)

import Utils.React as React exposing (React)
import Apps.BackFlix.Config exposing (..)
import Apps.BackFlix.Models exposing (..)
import Apps.BackFlix.Messages as BackFlix exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> BackFlix.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        UpdateTextFilter filter ->
            onUpdateFilter config filter model

        GoTab tab ->
            onGoTabs config tab model


onGoTabs : Config msg -> MainTab -> Model -> UpdateResponse msg
onGoTabs config tab model =
    let
        model_ =
            { model | selected = tab }
    in
        ( model_, React.none )


onUpdateFilter : Config msg -> String -> Model -> UpdateResponse msg
onUpdateFilter config filter model =
    ( model, React.none )
