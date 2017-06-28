module Game.Models
    exposing
        ( Model
        , initialModel
        , getActiveServerID
        , getActiveServer
        )

import Dict
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


getActiveServerID : Model -> String
getActiveServerID ({ meta, network } as model) =
    case meta.session of
        Meta.Gateway ->
            network.gateway

        Meta.Endpoint ->
            network.endpoint
                |> Maybe.andThen (flip Network.getServerID network)
                |> Maybe.withDefault network.gateway


getActiveServer : Model -> Maybe Servers.Server
getActiveServer ({ servers } as model) =
    Dict.get (getActiveServerID model) servers
