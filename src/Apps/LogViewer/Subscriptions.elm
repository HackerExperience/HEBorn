module Apps.LogViewer.Subscriptions exposing (..)

import Game.Models as Game
import Apps.LogViewer.Models exposing (Model)
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Menu.Subscriptions as Menu


subscriptions : Game.Model -> Model -> Sub Msg
subscriptions game model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
