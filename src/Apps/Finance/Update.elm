module Apps.Finance.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Finance.Models exposing (Model, MainTab)
import Apps.Finance.Messages as Finance exposing (Msg(..))


type alias UpdateResponse =
    ( Model, Cmd Finance.Msg, Dispatch )


update :
    Game.Data
    -> Finance.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        GoTab tab ->
            onGoTabs data tab model


onGoTabs : Game.Data -> MainTab -> Model -> UpdateResponse
onGoTabs data tab model =
    let
        model_ =
            { model | selected = tab }
    in
        Update.fromModel model_
