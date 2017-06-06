module Apps.LogViewer.Subscriptions exposing (..)

import Game.Models exposing (GameModel)
import Apps.LogViewer.Models exposing (Model)
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Menu.Subscriptions as Menu


subscriptions : GameModel -> Model -> Sub Msg
subscriptions game model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
