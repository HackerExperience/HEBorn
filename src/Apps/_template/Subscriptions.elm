module Apps.Template.Subscriptions exposing (..)

import Game.Data as Game
import Apps.Template.Models exposing (Model)
import Apps.Template.Messages exposing (Msg(..))
import Apps.Template.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
