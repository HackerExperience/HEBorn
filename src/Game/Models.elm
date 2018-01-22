module Game.Models
    exposing
        ( Model
        , initialModel
        , getAccount
        , setAccount
        , getInventory
        , setInventory
        , getServers
        , setServers
        , getMeta
        , setMeta
        , getStory
        , setStory
        , getWeb
        , setWeb
        , getBackFlix
        , setBackFlix
        , getFlags
        , unsafeGetGateway
        , getGateway
        , setGateway
        , getEndpoint
        , setEndpoint
        , getActiveServer
        , setActiveServer
        , getBounces
        , fallToGateway
        )

import Dict
import Native.Panic
import Core.Error as Error
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Inventory.Models as Inventory
import Game.Servers.Shared as Servers
import Game.Meta.Types.Context exposing (..)
import Game.Meta.Models as Meta
import Game.Storyline.Models as Story
import Game.Web.Models as Web
import Game.BackFlix.Models as BackFlix
import Core.Flags exposing (Flags)


type alias Model =
    { account : Account.Model
    , inventory : Inventory.Model
    , servers : Servers.Model
    , meta : Meta.Model
    , story : Story.Model
    , web : Web.Model
    , flags : Flags
    , backflix : BackFlix.Model
    }



-- Initializer


initialModel :
    Account.ID
    -> Account.Username
    -> Account.Token
    -> Flags
    -> Model
initialModel id username token flags =
    { account = Account.initialModel id username token
    , inventory = Inventory.initialModel
    , servers = Servers.initialModel
    , meta = Meta.initialModel
    , story = Story.initialModel
    , web = Web.initialModel
    , backflix = BackFlix.initialModel
    , flags = flags
    }



-- Getters + Setters

getAccount : Model -> Account.Model
getAccount =
    .account


setAccount : Account.Model -> Model -> Model
setAccount account model =
    { model | account = account }


getInventory : Model -> Inventory.Model
getInventory =
    .inventory


setInventory : Inventory.Model -> Model -> Model
setInventory inventory model =
    { model | inventory = inventory }


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


getBackFlix : Model -> BackFlix.Model
getBackFlix =
    .backflix


setBackFlix : BackFlix.Model -> Model -> Model
setBackFlix backflix model =
    { model | backflix = backflix }


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


getFlags : Model -> Flags
getFlags =
    .flags



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
            "Player has no active gateway! [2]"
                |> Error.astralProj
                |> uncurry Native.Panic.crash


fallToGateway : Model -> (Bool -> Account.Model) -> Account.Model
fallToGateway model callback =
    let
        servers =
            getServers model

        endpoint =
            model_
                |> Account.getGateway
                |> Maybe.andThen (flip Servers.get servers)
                |> Maybe.andThen Servers.getEndpointCId

        model_ =
            getAccount model
    in
        callback <| Account.getContext model_ == Endpoint && endpoint == Nothing


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
