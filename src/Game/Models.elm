module Game.Models
    exposing
        ( Model
        , initialModel
        , getAccount
        , getServers
        , getNetwork
        , getMeta
        , getConfig
        , setAccount
        , setServers
        , setMeta
        )

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


getAccount : Model -> Account.Model
getAccount =
    .account


setAccount : Account.Model -> Model -> Model
setAccount account model =
    { model | account = account }


getServers : Model -> Servers.Model
getServers =
    .servers


setServers : Servers.Model -> Model -> Model
setServers servers model =
    { model | servers = servers }


getNetwork : Model -> Network.Model
getNetwork =
    .network


setNetwork : Network.Model -> Model -> Model
setNetwork network model =
    { model | network = network }


getMeta : Model -> Meta.Model
getMeta =
    .meta


setMeta : Meta.Model -> Model -> Model
setMeta meta model =
    { model | meta = meta }


getConfig : Model -> Config
getConfig =
    .config
