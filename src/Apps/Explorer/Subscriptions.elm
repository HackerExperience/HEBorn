module Apps.Explorer.Subscriptions exposing (..)

import Game.Models as Game
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Menu.Subscriptions as Menu


subscriptions : Game.Model -> Model -> Sub Msg
subscriptions game model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
