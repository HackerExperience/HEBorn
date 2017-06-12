module Apps.Explorer.Subscriptions exposing (..)

import Game.Models exposing (GameModel)
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Menu.Subscriptions as Menu


subscriptions : GameModel -> Model -> Sub Msg
subscriptions game model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
