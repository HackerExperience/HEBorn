module Game.Models exposing (Model, initialModel)

import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Network.Models as Network
import Game.Meta.Models as Meta
import Core.Config exposing (Config)


type alias Model =
    { account : Account.Model
    , servers : Servers.Model
    , network : Network.Model
    , meta : Meta.Model
    , config : Config
    }


initialModel : String -> Config -> Model
initialModel token config =
    { account = Account.initialModel token
    , servers = Servers.initialModel
    , network = Network.initialModel
    , meta = Meta.initialModel
    , config = config
    }
