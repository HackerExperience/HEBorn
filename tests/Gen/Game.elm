module Gen.Game exposing (..)

import Game.Models exposing (..)
import Game.Account.Models exposing (..)
import Game.Software.Models exposing (..)
import Game.Server.Models exposing (..)
import Game.Network.Models exposing (..)
import Game.Meta.Models exposing (..)
import Gen.Utils exposing (..)
import Gen.Software exposing (..)


model : Int -> GameModel
model seedInt =
    { account = initialAccountModel
    , server = initialServerModel
    , network = initialNetworkModel
    , software = initialSoftwareModel
    , meta = initialMetaModel
    }
