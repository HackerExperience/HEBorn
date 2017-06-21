module Game.Models exposing (Model, initialModel)

import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Network.Models as Network
import Game.Meta.Models as Meta


type alias Model =
    { account : Account.Model
    , servers : Servers.Model
    , network : Network.Model
    , meta : Meta.Model
    }


initialModel : String -> String -> String -> Model
initialModel apiHttpUrl apiWsUrl version =
    { account = Account.initialModel
    , servers = Servers.initialModel
    , network = Network.initialModel
    , meta = Meta.initialModel apiHttpUrl apiWsUrl version
    }
