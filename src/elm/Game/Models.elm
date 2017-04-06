module Game.Models exposing ( GameModel, initialModel
                            , ResponseType)


import Dict

import Requests.Models exposing (Response)
import Game.Messages exposing (GameMsg)
import Game.Shared exposing (..)
import Game.Account.Models exposing (..)
import Game.Software.Models exposing (..)
import Game.Server.Models exposing (..)
import Game.Network.Models exposing (..)
import Game.Meta.Models exposing (..)


type alias ResponseType
    = Response
    -> GameModel
    -> (GameModel, Cmd GameMsg, List GameMsg)


type alias GameModel =
    { account : AccountModel
    , server : ServerModel
    , network : NetworkModel
    , software : SoftwareModel
    , meta : MetaModel
    }


initialModel : GameModel
initialModel =
    { account = initialAccountModel
    , server = initialServerModel
    , network = initialNetworkModel
    , software = initialSoftwareModel
    , meta = initialMetaModel
    }
