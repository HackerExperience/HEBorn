module Game.Servers.Notifications.Models exposing (..)

import Game.Meta.Types.Notifications exposing (..)
import Game.Servers.Notifications.Shared exposing (..)


type alias Model =
    Notifications Content


initialModel : Model
initialModel =
    empty
