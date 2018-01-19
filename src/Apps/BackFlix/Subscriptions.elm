module Apps.BackFlix.Subscriptions exposing (..)

import Game.Data as Game
import Apps.BackFlix.Models exposing (Model)
import Apps.BackFlix.Messages exposing (Msg(..))
import Apps.BackFlix.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
