module Apps.Calculator.Subscriptions exposing (..)

import Game.Data as Game
import Apps.Calculator.Models exposing (Model)
import Apps.Calculator.Messages exposing (Msg(..))
import Apps.Calculator.Menu.Subscriptions as Menu
import Keyboard


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.batch
        [ Sub.map MenuMsg (Menu.subscriptions model.menu)
        , Keyboard.downs KeyMsg
        ]
