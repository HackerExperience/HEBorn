module Apps.BounceManager.Subscriptions exposing (..)

import Game.Data as Game
import Apps.BounceManager.Models exposing (Model)
import Apps.BounceManager.Messages exposing (Msg(..))
import Apps.BounceManager.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
