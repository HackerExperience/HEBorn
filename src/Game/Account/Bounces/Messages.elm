module Game.Account.Bounces.Messages exposing (..)

import Game.Account.Bounces.Models exposing (Bounce)
import Game.Account.Bounces.Shared exposing (ID)
import Game.Meta.Types.Desktop.Apps exposing (Reference)


type Msg
    = HandleCreated String ID Bounce
    | HandleUpdated ID Bounce
    | HandleRemoved ID
    | HandleWaitForBounce String Reference
    | HandleRequestReload ID Reference
