module Game.Models exposing (..)

import Dict

import Game.Shared exposing (..)
import Game.Account.Models exposing (..)
import Game.Software.Models exposing (..)
import Game.Server.Models exposing (..)
import Game.Network.Models exposing (..)


type alias GameModel =
    { account : AccountModel
    , server : ServerModel
    , network : NetworkModel
    , software : SoftwareModel
    }


initialModel : GameModel
initialModel =
    { account = initialAccountModel
    , server = initialServerModel
    , network = initialNetworkModel
    , software = initialSoftwareModel
    }
