module OS.Header.Notifications.Subscriptions exposing (subscriptions)

import Game.Data as Game
import OS.Header.Notifications.Models exposing (..)
import OS.Header.Notifications.Messages exposing (..)


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none
