module Apps.TaskManager.Subscriptions exposing (..)

import Time exposing (Time, every, second)
import Game.Models as Game
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages exposing (Msg(..))
import Apps.TaskManager.Menu.Subscriptions as Menu


subscriptions : Game.Model -> Model -> Sub Msg
subscriptions game model =
    Sub.batch
        [ Sub.map MenuMsg (Menu.subscriptions model.menu)
        , Time.every second Tick
        ]
