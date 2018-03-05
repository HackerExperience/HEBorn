module Apps.BounceManager.Shared exposing (..)

import Game.Account.Bounces.Shared as Bounces


type Params
    = WithBounce Bounces.ID
