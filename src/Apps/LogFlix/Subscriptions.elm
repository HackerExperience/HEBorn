module Apps.LogFlix.Subscriptions exposing (..)

import Game.Data as Game
import Apps.LogFlix.Models exposing (Model)
import Apps.LogFlix.Messages exposing (Msg(..))
import Apps.LogFlix.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
