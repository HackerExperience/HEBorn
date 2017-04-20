module Game.Models
    exposing
        ( GameModel
        , initialModel
        , ResponseType
        )

import Requests.Models exposing (Response)
import Core.Messages exposing (CoreMsg)
import Game.Messages exposing (GameMsg)
import Game.Account.Models exposing (..)
import Game.Servers.Models exposing (..)
import Game.Network.Models exposing (..)
import Game.Meta.Models exposing (..)


type alias ResponseType =
    Response
    -> GameModel
    -> ( GameModel, Cmd GameMsg, List CoreMsg )


type alias GameModel =
    { account : AccountModel
    , servers : Servers
    , network : NetworkModel
    , meta : MetaModel
    }


initialModel : GameModel
initialModel =
    { account = initialAccountModel
    , servers = initialServers
    , network = initialNetworkModel
    , meta = initialMetaModel
    }
