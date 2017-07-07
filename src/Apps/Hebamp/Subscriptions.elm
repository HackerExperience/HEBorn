module Apps.Hebamp.Subscriptions exposing (..)

import Game.Data as Game
import Apps.Hebamp.Models exposing (Model)
import Apps.Hebamp.Messages exposing (Msg(..))
import Apps.Hebamp.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
