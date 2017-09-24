module Apps.Bug.Subscriptions exposing (..)

import Game.Data as Game
import Apps.Bug.Models exposing (Model)
import Apps.Bug.Messages exposing (Msg(..))
import Apps.Bug.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
