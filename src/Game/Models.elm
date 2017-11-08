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
        , getStory
        , setStory
        , getConfig
        , unsafeGetGateway
        , getGateway
        , setGateway
        , getEndpoint
        , setEndpoint
        , getActiveServer
        , setActiveServer
        , getBounces
        )

import Dict
import Native.Panic
import Core.Error as Error
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Meta.Types exposing (..)
import Game.Meta.Models as Meta
import Game.Storyline.Models as Story
import Game.Web.Models as Web
import Core.Config exposing (Config)


type alias Model =
    { account : Account.Model
    , servers : Servers.Model
    , meta : Meta.Model
    , story : Story.Model
    , web : Web.Model
    , config : Config
    }



-- Initializer


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
    , story = Story.initialModel
    , web = Web.initialModel
    , config = config
    }



-- Getters + Setters


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


getStory : Model -> Story.Model
getStory =
    .story


setStory : Story.Model -> Model -> Model
setStory story model =
    { model | story = story }


getWeb : Model -> Web.Model
getWeb =
    .web


setWeb : Web.Model -> Model -> Model
setWeb web model =
    { model | web = web }


getConfig : Model -> Config
getConfig =
    .config



-- Gateway / Endpoint (Getter + Setter)


getGateway : Model -> Maybe ( Servers.CId, Servers.Server )
getGateway model =
    let
        servers =
            getServers model
    in
        model
            |> getAccount
            |> Account.getGateway
            |> Maybe.andThen
                (\serverCId ->
                    servers
                        |> Servers.get serverCId
                        |> Maybe.map ((,) serverCId)
                )


unsafeGetGateway : Model -> ( Servers.CId, Servers.Server )
unsafeGetGateway model =
    case getGateway model of
        Just server ->
            server

        Nothing ->
            "Player has no active gateway!"
                |> Error.astralProj
                |> uncurry Native.Panic.crash


setGateway : Servers.Server -> Model -> Model
setGateway server model =
    case getGateway model of
        Just ( cid, _ ) ->
            setServer cid server model

        Nothing ->
            model


getEndpoint : Model -> Maybe ( Servers.CId, Servers.Server )
getEndpoint model =
    let
        servers =
            getServers model

        maybeGateway =
            getGateway model
                |> Maybe.map Tuple.second

        maybeEndpointCId =
            Maybe.andThen Servers.getEndpointCId maybeGateway

        maybeEndpoint =
            Maybe.andThen (flip Servers.get servers) maybeEndpointCId
    in
        case ( maybeEndpointCId, maybeEndpoint ) of
            ( Just cid, Just endpoint ) ->
                Just ( cid, endpoint )

            _ ->
                Nothing


setEndpoint : Servers.Server -> Model -> Model
setEndpoint server model =
    case getEndpoint model of
        Just ( cid, _ ) ->
            setServer cid server model

        Nothing ->
            model


getActiveServer : Model -> Maybe ( Servers.CId, Servers.Server )
getActiveServer model =
    case Account.getContext <| getAccount model of
        Gateway ->
            getGateway model

        Endpoint ->
            getEndpoint model


setActiveServer : Servers.Server -> Model -> Model
setActiveServer server model =
    case Account.getContext <| getAccount model of
        Gateway ->
            setGateway server model

        Endpoint ->
            setEndpoint server model



-- common helpers


getBounces : Model -> List String
getBounces game =
    game
        |> getAccount
        |> (.bounces)
        |> Dict.keys



-- internals


setServer : Servers.CId -> Servers.Server -> Model -> Model
setServer cid server model =
    let
        meta =
            getMeta model

        servers =
            getServers model

        servers_ =
            Servers.insert cid server servers

        model_ =
            setServers servers_ model
    in
        model_
