module Apps.Popup.Subscriptions exposing (..)

import Game.Data as Game
import Apps.Popup.Models exposing (Model)
import Apps.Popup.Messages exposing (Msg(..))
import Apps.Popup.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
