module Game.Models exposing (GameModel, initialModel)

import Game.Account.Models exposing (..)
import Game.Servers.Models exposing (..)
import Game.Network.Models exposing (..)
import Game.Meta.Models exposing (..)


type alias GameModel =
    { account : AccountModel
    , servers : Servers
    , network : NetworkModel
    , meta : MetaModel
    }


initialModel : String -> String -> String -> GameModel
initialModel apiHttpUrl apiWsUrl version =
    { account = initialAccountModel
    , servers = initialServers
    , network = initialNetworkModel
    , meta = initialMetaModel apiHttpUrl apiWsUrl version
    }
