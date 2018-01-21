module Apps.DBAdmin.Subscriptions exposing (..)

import Game.Data as Game
import Apps.DBAdmin.Config exposing (..)
import Apps.DBAdmin.Models exposing (Model)
import Apps.DBAdmin.Messages exposing (Msg(..))
import Apps.DBAdmin.Menu.Subscriptions as Menu


subscriptions : Config msg -> Model -> Sub Msg
subscriptions config model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
