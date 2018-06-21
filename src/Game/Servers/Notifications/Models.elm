module Game.Servers.Notifications.Models exposing (..)

{-| Model de notificações pertencentes a um server.
-}

import Game.Meta.Types.Notifications exposing (..)
import Game.Servers.Notifications.Shared exposing (..)


{-| A model é uma data structure genérica para notificações
-}
type alias Model =
    Notifications Content


{-| Model inicial.
-}
initialModel : Model
initialModel =
    empty
