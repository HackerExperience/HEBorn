module Game.Servers.Web.Requests.DNS
    exposing
        ( Response(..)
        , request
        , receive
        )

import Game.Servers.Web.Types as Web
import Game.Servers.Web.Messages exposing (..)
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (ConfigSource, Code(..))
import Utils.Json.Decode exposing (exclusively)
import Json.Decode as Decode exposing (Decoder, Value, decodeValue)
import Json.Decode.Pipeline as Encode
    exposing
        ( decode
        , required
        )
import Json.Encode as Encode


-- This is mostly a poc


type Response
    = Okay Web.Site


type Root
    = VpcRoot Vpc
    | NpcRoot Npc


type alias Vpc =
    { vpc : VpcSites }


type alias Npc =
    { npc : NpcSites }


type VpcSites
    = WebserverSite Webserver
    | NoWebserverSite NoWebserver


type NpcSites
    = BankSite Bank


type alias Webserver =
    { web : String }


type alias NoWebserver =
    { web : String }


type alias Bank =
    { type_ : String
    , bank : String
    }


request : String -> ConfigSource a -> Cmd Msg
request url =
    -- TODO: change topic to target the correct request
    Requests.request AccountLogoutTopic
        (DNSRequest url >> Request)
        Nothing
        (encoder url)


receive : String -> Code -> Value -> Maybe Response
receive url code json =
    case code of
        OkCode ->
            json
                |> decoder url
                |> Result.map Okay
                |> Result.toMaybe

        _ ->
            Nothing



-- internals


encoder : String -> Value
encoder url =
    Encode.object [ ( "url", Encode.string url ) ]


decoder : String -> Value -> Result String Web.Site
decoder url json =
    case decodeValue root json of
        Ok root ->
            Ok (convert url root)

        Err reason ->
            Err reason


convert : String -> Root -> Web.Site
convert url root =
    case root of
        VpcRoot { vpc } ->
            case vpc of
                WebserverSite meta ->
                    { type_ = Web.Webserver
                    , url = url
                    , meta = Just (Web.WebserverMeta { serverId = "TODO", nip = ( "", "" ) })
                    }

                NoWebserverSite meta ->
                    { type_ = Web.NoWebserver
                    , url = url
                    , meta = Just (Web.NoWebserverMeta { serverId = "TODO", nip = ( "", "" ) })
                    }

        NpcRoot { npc } ->
            case npc of
                BankSite meta ->
                    { type_ = Web.Bank
                    , url = url
                    , meta = Just (Web.BankMeta {})
                    }


root : Decoder Root
root =
    Decode.oneOf
        [ Decode.map NpcRoot npc
        , Decode.map VpcRoot vpc
        ]


npc : Decoder Npc
npc =
    decode Npc
        |> required "npc" npcSites


vpc : Decoder Vpc
vpc =
    decode Vpc
        |> required "vpc" vpcSites


npcSites : Decoder NpcSites
npcSites =
    Decode.oneOf
        [ Decode.map BankSite bank ]


vpcSites : Decoder VpcSites
vpcSites =
    Decode.oneOf
        [ Decode.map WebserverSite custom
        , Decode.map NoWebserverSite default
        ]


custom : Decoder Webserver
custom =
    -- TODO: the string type here is temporary
    decode Webserver
        |> required "web" Decode.string


default : Decoder NoWebserver
default =
    -- TODO: the string type here is temporary
    decode NoWebserver
        |> required "web" Decode.string


bank : Decoder Bank
bank =
    -- TODO: the string type here is temporary
    decode Bank
        |> required "type" (exclusively "bank" Decode.string)
        |> required "bank" Decode.string
