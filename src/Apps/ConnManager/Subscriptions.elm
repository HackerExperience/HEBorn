module Apps.ConnManager.Subscriptions exposing (..)

import Game.Data as Game
import Apps.ConnManager.Models exposing (Model)
import Apps.ConnManager.Messages exposing (Msg(..))
import Apps.ConnManager.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
