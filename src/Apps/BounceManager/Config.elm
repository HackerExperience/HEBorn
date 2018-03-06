module Apps.BounceManager.Config exposing (..)

import Core.Flags exposing (Flags)
import Game.Meta.Types.Apps.Desktop exposing (Reference)
import Game.Account.Bounces.Models as Bounces
import Game.Account.Database.Models as Database
import Apps.BounceManager.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , flags : Flags
    , batchMsg : List msg -> msg
    , awaitEvent : String -> ( String, msg ) -> msg
    , reference : Reference
    , bounces : Bounces.Model
    , database : Database.Model
    , accountId : String
    }
