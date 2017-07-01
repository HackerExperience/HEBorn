module Game.Web.Requests.DNS
    exposing
        ( Response(..)
        , request
        , receive
        )

import Game.Web.Types as Web
import Game.Web.Messages exposing (..)
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
    = OkResponse Web.Site
    | ErrorResponse


type Root
    = VpcRoot Vpc
    | NpcRoot Npc


type alias Vpc =
    { vpc : VpcSites }


type alias Npc =
    { npc : NpcSites }


type VpcSites
    = CustomSite Custom
    | DefaultSite Default


type NpcSites
    = BankSite Bank


type alias Custom =
    { web : String }


type alias Default =
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


receive : String -> Code -> Value -> Response
receive url code json =
    case code of
        OkCode ->
            json
                |> decoder url
                |> Result.map OkResponse
                |> Requests.report

        _ ->
            ErrorResponse



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
                CustomSite meta ->
                    { type_ = Web.Custom
                    , url = url
                    , meta = Just (Web.CustomMeta {})
                    }

                DefaultSite meta ->
                    { type_ = Web.Default
                    , url = url
                    , meta = Just (Web.DefaultMeta { wip = "" })
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
        [ Decode.map CustomSite custom
        , Decode.map DefaultSite default
        ]


custom : Decoder Custom
custom =
    -- TODO: the string type here is temporary
    decode Custom
        |> required "web" Decode.string


default : Decoder Default
default =
    -- TODO: the string type here is temporary
    decode Default
        |> required "web" Decode.string


bank : Decoder Bank
bank =
    -- TODO: the string type here is temporary
    decode Bank
        |> required "type" (exclusively "bank" Decode.string)
        |> required "bank" Decode.string
