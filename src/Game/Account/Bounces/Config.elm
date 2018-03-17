module Game.Account.Bounces.Config exposing (Config)

import Core.Flags as Core
import Game.Account.Bounces.Messages exposing (..)
import Game.Account.Bounces.Shared exposing (ID)
import Game.Account.Database.Models as Database


type alias Config msg =
    { flags : Core.Flags
    , batchMsg : List msg -> msg
    , toMsg : Msg -> msg
    , accountId : String
    , database : Database.Model
    , onReloadBounce : ID -> String -> msg
    , onReloadIfBounceLoaded : ID -> msg
    }
