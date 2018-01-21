module Apps.LogViewer.Subscriptions exposing (..)

import Game.Data as Game
import Apps.LogViewer.Config exposing (..)
import Apps.LogViewer.Models exposing (Model)
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Menu.Subscriptions as Menu


subscriptions : Config msg -> Model -> Sub Msg
subscriptions config model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
