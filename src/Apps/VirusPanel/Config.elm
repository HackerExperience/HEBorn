module Apps.VirusPanel.Config exposing (..)

import Core.Flags exposing (Flags)
import Game.Account.Bounces.Models as Bounces
import Game.Account.Database.Models as Database
import Game.Account.Finances.Models as Finances
import Game.Servers.Shared as Servers
import Game.Servers.Processes.Models as Processes
import Apps.VirusPanel.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , awaitEvent : String -> ( String, msg ) -> msg
    , flags : Flags
    , accountId : String
    , database : Database.Model
    , processes : Processes.Model
    , finances : Finances.Model
    , bounces : Bounces.Model
    , activeGatewayCId : Servers.CId
    }
