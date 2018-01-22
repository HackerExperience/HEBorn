module Apps.BounceManager.Config exposing (..)

import Game.Account.Bounces.Models as Bounces
import Game.Account.Database.Models as Database
import Apps.BounceManager.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , bounces : Bounces.Model
    , database : Database.Model
    }
