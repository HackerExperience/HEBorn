module Apps.DBAdmin.Subscriptions exposing (..)

import Game.Data as Game
import Apps.DBAdmin.Models exposing (Model)
import Apps.DBAdmin.Messages exposing (Msg(..))
import Apps.DBAdmin.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
