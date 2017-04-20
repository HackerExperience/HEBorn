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
import Game.Server.Models exposing (..)
import Game.Network.Models exposing (..)
import Game.Meta.Models exposing (..)


type alias ResponseType =
    Response
    -> GameModel
    -> ( GameModel, Cmd GameMsg, List CoreMsg )


type alias GameModel =
    { account : AccountModel
    , server : ServerModel
    , network : NetworkModel
    , meta : MetaModel
    }


initialModel : GameModel
initialModel =
    { account = initialAccountModel
    , server = initialServerModel
    , network = initialNetworkModel
    , meta = initialMetaModel
    }
