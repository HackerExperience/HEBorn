module Game.Web.Requests.DNS
    exposing
        ( request
        , receive
        )

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , andThen
        , field
        , succeed
        , map
        , fail
        , nullable
        , list
        , maybe
        , string
        , float
        )
import Json.Decode.Pipeline as Encode
    exposing
        ( decode
        , optional
        , required
        , hardcoded
        )
import Json.Encode as Encode
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Decoders.Network
import Decoders.Filesystem
import Game.Servers.Shared as Servers
import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Web.Types exposing (..)
import Game.Web.Messages exposing (..)


request :
    String
    -> Network.ID
    -> Servers.CId
    -> Requester
    -> FlagsSource a
    -> Cmd Msg
request url networkId cid requester =
    Requests.request (Topics.browse cid)
        (DNSRequest url requester >> Request)
        (encoder networkId url)


receive : String -> Code -> Value -> Maybe Response
receive url code json =
    case code of
        OkCode ->
            json
                |> decodeValue (decoder url)
                |> Requests.report

        ErrorCode ->
            Requests.decodeGenericError
                json
                (decodeErrorMessage url)

        _ ->
            Just <| ConnectionError url



-- internals


encoder : Network.ID -> Url -> Value
encoder nid url =
    Encode.object
        [ ( "network_id", Encode.string nid )
        , ( "address", Encode.string url )
        ]


decoder : Url -> Decoder Response
decoder url =
    field "type" string
        |> andThen (decodeType >> field "content")
        |> andThen (decodeSite url)
        |> map PageLoaded


decodeType : String -> Decoder Type
decodeType typeStr =
    case typeStr of
        "home" ->
            succeed Home

        "profile" ->
            succeed Profile

        "vpc" ->
            decodeWeb

        "npc_whois" ->
            succeed Whois

        "npc_download_center" ->
            decodeDownloadCenter

        "npc_isp" ->
            succeed ISP

        "npc_bank" ->
            decodeBank

        "npc_store" ->
            succeed Store

        "npc_btc" ->
            succeed BTC

        "npc_fbi" ->
            succeed FBI

        "npc_news" ->
            succeed News

        "npc_bithub" ->
            succeed Bithub

        "npc_missions" ->
            succeed MissionCenter

        _ ->
            fail "Unknown web page type"


decodeSite : Url -> Type -> Decoder Site
decodeSite url type_ =
    decode (Site url type_)
        |> required "meta" decodeMeta


decodeMeta : Decoder Meta
decodeMeta =
    decode Meta
        |> optional "password" (nullable string) Nothing
        |> required "nip" Decoders.Network.nipTuple
        |> optional "public" (list Decoders.Filesystem.fileEntry) []


decodeWeb : Decoder Type
decodeWeb =
    decode WebserverContent
        |> hardcoded "TODO"
        |> map Webserver


decodeBank : Decoder Type
decodeBank =
    decode BankContent
        |> required "title" string
        |> required "nip" Decoders.Network.nipTuple
        |> map Bank


decodeDownloadCenter : Decoder Type
decodeDownloadCenter =
    decode DownloadCenterContent
        |> required "title" string
        |> map DownloadCenter


decodeErrorMessage : Url -> String -> Decoder Response
decodeErrorMessage url str =
    case str of
        "web_not_found" ->
            succeed <| PageNotFound url

        _ ->
            fail "Unknown dns request error message"
