module Game.Models.Game exposing (..)

import Dict

import Game.Models.Shared exposing (..)
import Game.Models.Account exposing (..)
import Game.Models.Software exposing (..)
import Game.Models.Server exposing (..)
import Game.Models.Network exposing (..)


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
