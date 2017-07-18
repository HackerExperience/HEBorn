module Apps.CtrlPanel.Subscriptions exposing (..)

import Game.Data as Game
import Apps.CtrlPanel.Models exposing (Model)
import Apps.CtrlPanel.Messages exposing (Msg(..))
import Apps.CtrlPanel.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
