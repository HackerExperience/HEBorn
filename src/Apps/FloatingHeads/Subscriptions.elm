module Apps.FloatingHeads.Subscriptions exposing (..)

import Game.Data as Game
import Apps.FloatingHeads.Models exposing (Model)
import Apps.FloatingHeads.Messages exposing (Msg(..))


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.none
