module Apps.Browser.Subscriptions exposing (..)

import Game.Models as Game
import Apps.Browser.Models exposing (Model)
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Menu.Subscriptions as Menu


subscriptions : Game.Model -> Model -> Sub Msg
subscriptions game model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
