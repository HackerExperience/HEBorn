module Apps.FloatingHeads.Subscriptions exposing (..)

import Game.Data as Game
import Apps.FloatingHeads.Models exposing (Model)
import Apps.FloatingHeads.Messages exposing (Msg(..))
import Apps.FloatingHeads.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
