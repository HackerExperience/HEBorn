module Apps.ServersGears.Subscriptions exposing (..)

import Game.Data as Game
import Apps.ServersGears.Models exposing (Model)
import Apps.ServersGears.Messages exposing (Msg(..))
import Apps.ServersGears.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
