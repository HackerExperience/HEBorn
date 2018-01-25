module Apps.BounceManager.Config exposing (..)

import Core.Flags exposing (Flags)
import Game.Account.Bounces.Models as Bounces
import Game.Account.Database.Models as Database
import Apps.BounceManager.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , flags : Flags
    , bounces : Bounces.Model
    , database : Database.Model
    , batchMsg : List msg -> msg
    , accountId : String
    }
