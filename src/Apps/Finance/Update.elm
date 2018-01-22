module Apps.Finance.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Data as Game
import Apps.Finance.Config exposing (..)
import Apps.Finance.Models exposing (Model, MainTab)
import Apps.Finance.Messages as Finance exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Finance.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        GoTab tab ->
            onGoTabs config tab model


onGoTabs : Config msg -> MainTab -> Model -> UpdateResponse msg
onGoTabs config tab model =
    let
        model_ =
            { model | selected = tab }
    in
        ( model_, React.none )
