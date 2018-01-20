module Game.Account.Notifications.Models exposing (..)

import Game.Meta.Types.Notifications exposing (..)
import Game.Account.Notifications.Shared exposing (..)


type alias Model =
    Notifications Content


initialModel : Model
initialModel =
    empty
