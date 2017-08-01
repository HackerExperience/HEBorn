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
        , getGateway
        , setGateway
        , getEndpoint
        , setEndpoint
        , getActiveServer
        , setActiveServer
        )

import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Meta.Types as Meta
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


initialModel :
    Account.ID
    -> Account.Username
    -> Account.Token
    -> Config
    -> Model
initialModel id username token config =
    { account = Account.initialModel id username token
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


getGateway : Model -> Maybe ( Servers.ID, Servers.Server )
getGateway model =
    let
        meta =
            getMeta model

        servers =
            getServers model

        maybeGatewayID =
            Meta.getGateway meta

        maybeGateway =
            Maybe.andThen (flip Servers.get servers) maybeGatewayID
    in
        case ( maybeGatewayID, maybeGateway ) of
            ( Just id, Just gateway ) ->
                Just ( id, gateway )

            _ ->
                Nothing


setGateway : Servers.Server -> Model -> Model
setGateway server model =
    case getGateway model of
        Just ( id, _ ) ->
            setServer id server model

        Nothing ->
            model


getEndpoint : Model -> Maybe ( Servers.ID, Servers.Server )
getEndpoint model =
    let
        meta =
            getMeta model

        servers =
            getServers model

        maybeGateway =
            meta
                |> Meta.getGateway
                |> Maybe.andThen (flip Servers.get servers)

        maybeEndpointID =
            maybeGateway
                |> Maybe.andThen Servers.getEndpoint
                |> Maybe.andThen (flip Servers.mapNetwork servers)

        maybeEndpoint =
            Maybe.andThen (flip Servers.get servers) maybeEndpointID
    in
        case ( maybeEndpointID, maybeEndpoint ) of
            ( Just id, Just endpoint ) ->
                Just ( id, endpoint )

            _ ->
                Nothing


setEndpoint : Servers.Server -> Model -> Model
setEndpoint server model =
    case getEndpoint model of
        Just ( id, _ ) ->
            setServer id server model

        Nothing ->
            model


getActiveServer : Model -> Maybe ( Servers.ID, Servers.Server )
getActiveServer model =
    let
        meta =
            getMeta model
    in
        case Meta.getContext meta of
            Meta.Gateway ->
                getGateway model

            Meta.Endpoint ->
                getEndpoint model


setActiveServer : Servers.Server -> Model -> Model
setActiveServer server model =
    let
        meta =
            getMeta model
    in
        case Meta.getContext meta of
            Meta.Gateway ->
                setGateway server model

            Meta.Endpoint ->
                setEndpoint server model



-- internals


setServer : Servers.ID -> Servers.Server -> Model -> Model
setServer id server model =
    let
        meta =
            getMeta model

        servers =
            getServers model

        servers_ =
            Servers.insert id server servers

        model_ =
            setServers servers_ model
    in
        model_
