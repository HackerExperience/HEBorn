module Apps.Email.Subscriptions exposing (..)

import Game.Data as Game
import Apps.Email.Models exposing (Model)
import Apps.Email.Messages exposing (Msg(..))
import Apps.Email.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
