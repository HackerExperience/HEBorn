module Game.Account.Requests.ServerIndex
    exposing
        ( Response(..)
        , request
        , receive
          -- response format types
        , Root
        , Servers
        , Server
        , Hardware
        , Components
        , Component
        , ComponentType(..)
        , Resources
        , Net
        , Meta
        , ServerType(..)
        )

import Dict exposing (Dict)
import Json.Decode
    exposing
        -- this request contains no payload, so no problems with importing this
        ( Decoder
        , Value
        , decodeValue
        , succeed
        , fail
        , andThen
        , list
        , string
        , int
        )
import Json.Decode.Extra exposing (dict2)
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)
import Game.Account.Messages exposing (..)


type Response
    = OkResponse Servers
    | NoOp


type alias Root =
    { servers : Servers }


type alias Servers =
    List Server


type alias Server =
    { hardware : Hardware
    , ips : List String
    , password : String
    , id : String
    , type_ : ServerType
    }


type alias Hardware =
    { components : Components
    , resources : Resources
    }


type alias Components =
    Dict Int Component


type alias Component =
    { id : String
    , type_ : ComponentType
    , meta : Meta
    }


type ComponentType
    = Mobo
    | Cpu
    | Ram
    | Hdd
    | Nic


type alias Resources =
    { cpu : Int
    , net : Net
    , ram : Int
    }


type alias Net =
    {}


type alias Meta =
    {}


type ServerType
    = Desktop
    | Mobile
    | Vps


request : String -> ConfigSource a -> Cmd Msg
request account =
    Requests.request AccountServerIndexTopic
        (ServerIndexRequest >> Request)
        (Just account)
        emptyPayload


receive : Code -> Value -> Response
receive code json =
    case code of
        OkCode ->
            json
                |> decoder
                |> Result.map OkResponse
                |> Requests.report

        _ ->
            -- TODO: handle errors
            NoOp



-- internals


decoder : Value -> Result String Servers
decoder json =
    case decodeValue root json of
        Ok root ->
            Ok root.servers

        Err reason ->
            Err reason


root : Decoder Root
root =
    decode Root
        |> required "servers" (list server)


server : Decoder Server
server =
    decode Server
        |> required "hardware" hardware
        |> required "ips" (list string)
        |> required "password" string
        |> required "server_id" string
        |> required "server_type" serverType


hardware : Decoder Hardware
hardware =
    decode Hardware
        |> required "components" (dict2 int component)
        |> required "resources" resources


component : Decoder Component
component =
    decode Component
        |> required "component_id" string
        |> required "component_type" componentType
        |> hardcoded {}


resources : Decoder Resources
resources =
    decode Resources
        |> required "cpu" int
        |> hardcoded {}
        |> required "ram" int


serverType : Decoder ServerType
serverType =
    string |> andThen decodeServerType


decodeServerType : String -> Decoder ServerType
decodeServerType str =
    case str of
        "desktop" ->
            succeed Desktop

        "mobile" ->
            succeed Mobile

        "vps" ->
            succeed Vps

        error ->
            fail <|
                "Trying to decode server_type, but value "
                    ++ toString error
                    ++ " is not supported."


componentType : Decoder ComponentType
componentType =
    string |> andThen decodeComponentType


decodeComponentType : String -> Decoder ComponentType
decodeComponentType str =
    case str of
        "mobo" ->
            succeed Mobo

        "cpu" ->
            succeed Cpu

        "ram" ->
            succeed Ram

        "hdd" ->
            succeed Hdd

        "nic" ->
            succeed Nic

        error ->
            fail <|
                "Trying to decode component_type, but value "
                    ++ toString error
                    ++ " is not supported."
