module Gen.Game exposing (..)

import Game.Models exposing (..)
import Game.Account.Models exposing (..)
import Game.Servers.Models exposing (..)
import Game.Network.Models exposing (..)
import Game.Meta.Models exposing (..)
import Gen.Utils exposing (..)
import Gen.Servers as Servers


model : Int -> GameModel
model seedInt =
    { account = initialAccountModel
    , servers = Servers.model seedInt
    , network = initialNetworkModel
    , meta = initialMetaModel
    }
