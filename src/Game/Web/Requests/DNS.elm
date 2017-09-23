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
        )
import Json.Encode as Encode
import Utils.Json.Decode exposing (exclusively)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Decoders.Network
import Game.Web.Types exposing (..)
import Game.Web.Messages exposing (..)
import Game.Web.Models exposing (Requester)


request :
    String
    -> String
    -> String
    -> Requester
    -> ConfigSource a
    -> Cmd Msg
request serverId url networkId requester =
    Requests.request Topics.browse
        (DNSRequest url requester >> Request)
        (Just serverId)
        (encoder url)


receive : String -> Code -> Value -> Maybe Response
receive url code json =
    case code of
        OkCode ->
            json
                |> decodeValue (decoder url)
                |> Requests.report

        ErrorCode ->
            Requests.decodeGenericError json
                (decodeErrorMessage url)
                |> Requests.report

        _ ->
            Just <| ConnectionError url



-- internals


encoder : Url -> Value
encoder url =
    Encode.object
        [ ( "url", Encode.string url )
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

        "vpc_web" ->
            decodeWeb

        "vpc_noweb" ->
            succeed NoWebserver

        "npc_whois" ->
            succeed Whois

        "npc_downcenter" ->
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
        |> required "nip" Decoders.Network.nip


decodeWeb : Decoder Type
decodeWeb =
    decode WebserverContent
        |> required "custom" string
        |> map Webserver


decodeBank : Decoder Type
decodeBank =
    decode BankContent
        |> required "title" string
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
            fail "Unexpected error"
