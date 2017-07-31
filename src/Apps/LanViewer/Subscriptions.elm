module Apps.LanViewer.Subscriptions exposing (..)

import Game.Data as Game
import Apps.LanViewer.Models exposing (Model)
import Apps.LanViewer.Messages exposing (Msg(..))
import Apps.LanViewer.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
