module Game.Models
    exposing
        ( Model
        , initialModel
        , getAccount
        , getServers
        , getMeta
        , getConfig
        , setAccount
        , setServers
        , setMeta
        , getServerIP
        , getServerID
        )

import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Servers.Tunnels.Models as Tunnels
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


getServerIP : Model -> Maybe Tunnels.IP
getServerIP model =
    let
        servers =
            getServers model
    in
        model
            |> getServerID
            |> Maybe.andThen (flip Servers.get servers)
            |> Maybe.map .ip


getServerID : Model -> Maybe Servers.ID
getServerID model =
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
                        |> Maybe.map .tunnels
                        |> Maybe.andThen Tunnels.getEndpoint
                        |> Maybe.andThen
                            (flip Servers.mapNetwork servers)
    in
        maybeServerID


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
