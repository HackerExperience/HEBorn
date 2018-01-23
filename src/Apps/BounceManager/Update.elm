module Apps.BounceManager.Update exposing (update)

import Utils.React as React exposing (React)
import Apps.BounceManager.Config exposing (..)
import Apps.BounceManager.Models exposing (Model, MainTab)
import Apps.BounceManager.Messages as BounceManager exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> BounceManager.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        GoTab tab ->
            onGoTab tab model


onGoTab : MainTab -> Model -> UpdateResponse msg
onGoTab tab model =
    let
        model_ =
            { model | selected = tab }
    in
        ( model_, React.none )
