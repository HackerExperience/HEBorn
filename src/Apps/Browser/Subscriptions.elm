module Apps.Browser.Subscriptions exposing (..)

import Game.Models exposing (GameModel)
import Apps.Browser.Models exposing (Model)
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Menu.Subscriptions as Menu


subscriptions : GameModel -> Model -> Sub Msg
subscriptions game model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
