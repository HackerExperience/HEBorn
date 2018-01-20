module Apps.BounceManager.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.BounceManager.Models exposing (Model, MainTab)
import Apps.BounceManager.Messages as BounceManager exposing (Msg(..))


type alias UpdateResponse =
    ( Model, Cmd BounceManager.Msg, Dispatch )


update :
    Game.Data
    -> BounceManager.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        GoTab tab ->
            onGoTab tab model


onGoTab : MainTab -> Model -> UpdateResponse
onGoTab tab model =
    let
        model_ =
            { model | selected = tab }
    in
        ( model_, Cmd.none, Dispatch.none )
