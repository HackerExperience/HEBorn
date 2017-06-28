module Apps.TaskManager.Subscriptions exposing (..)

import Time exposing (Time, every, second)
import Game.Data as Game
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages exposing (Msg(..))
import Apps.TaskManager.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.batch
        [ Sub.map MenuMsg (Menu.subscriptions model.menu)
        , Time.every second Tick
        ]
