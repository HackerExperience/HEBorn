module Game.Account.Bounces.Messages exposing (..)

import Game.Account.Bounces.Models exposing (Bounce)
import Game.Account.Bounces.Shared exposing (ID)


type Msg
    = HandleCreated ID Bounce
    | HandleUpdated ID Bounce
    | HandleRemoved ID
