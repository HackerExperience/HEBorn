module Game.Models
    exposing
        ( Model
        , initialModel
        , getAccount
        , setAccount
        , getServers
        , setServers
        , getMeta
        , setMeta
        , getConfig
        , getActiveServer
        , setActiveServer
        , getActiveServerID
        )

import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Meta.Models as Meta
import Game.Web.Models as Web
import Core.Config exposing (Config)


type alias Model =
    { account : Account.Model
    , servers : Servers.Model
    , meta : Meta.Model
    , web : Web.Model
    , config : Config
    }


initialModel : String -> Config -> Model
initialModel token config =
    { account = Account.initialModel token
    , servers = Servers.initialModel
    , meta = Meta.initialModel
    , web = Web.initialModel
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


getMeta : Model -> Meta.Model
getMeta =
    .meta


setMeta : Meta.Model -> Model -> Model
setMeta meta model =
    { model | meta = meta }


getConfig : Model -> Config
getConfig =
    .config


getActiveServer : Model -> Maybe Servers.Server
getActiveServer model =
    model
        |> getActiveServerID
        |> Maybe.andThen (flip Servers.get (getServers model))


setActiveServer : Servers.Server -> Model -> Model
setActiveServer server model =
    case getActiveServerID model of
        Just id ->
            let
                servers =
                    getServers model

                servers_ =
                    Servers.insert id server servers

                model_ =
                    setServers servers_ model
            in
                model_

        Nothing ->
            model


getActiveServerID : Model -> Maybe Servers.ID
getActiveServerID model =
    let
        meta =
            getMeta model

        servers =
            getServers model

        maybeGatewayID =
            Meta.getGateway meta

        maybeServerID =
            case Meta.getContext meta of
                Meta.Gateway ->
                    maybeGatewayID

                Meta.Endpoint ->
                    maybeGatewayID
                        |> Maybe.andThen (flip Servers.get servers)
                        |> Maybe.andThen .endpoint
                        |> Maybe.andThen
                            (flip Servers.mapNetwork servers)
    in
        maybeServerID
