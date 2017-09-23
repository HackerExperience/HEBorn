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
        , succeed
        , map
        , oneOf
        , fail
        , list
        , value
        , maybe
        , string
        , float
        )
import Json.Decode.Pipeline as Encode
    exposing
        ( decode
        , optional
        , required
        , resolve
        )
import Json.Encode as Encode
import Utils.Json.Decode exposing (exclusively)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Game.Network.Types exposing (NIP)
import Decoders.Network
import Game.Web.Types exposing (..)
import Game.Web.Messages exposing (..)
import Game.Web.DNS exposing (..)


request : String -> String -> String -> Requester -> ConfigSource a -> Cmd Msg
request serverId url networkId requester =
    Requests.request Topics.browse
        (DNSRequest url requester >> Request)
        (Just serverId)
        (encoder url networkId)


receive : String -> Code -> Value -> Maybe Response
receive url code json =
    case code of
        OkCode ->
            json
                |> decodeValue (decoder url)
                |> Requests.report

        ErrorCode ->
            Requests.decodeGenericError json (errorMessage url)
                |> Requests.report

        _ ->
            Just <| ConnectionError url



-- internals


errorMessage : Url -> String -> Decoder Response
errorMessage url str =
    case str of
        "web_not_found" ->
            succeed <| NotFounded url

        _ ->
            fail "Unexpected error"


encoder : String -> String -> Value
encoder url networkId =
    Encode.object
        [ ( "network_id", Encode.string networkId )
        , ( "address", Encode.string url )
        ]


decoder : Url -> Decoder Response
decoder url =
    oneOf
        [ decodeNpc url

        --, decodeVpc url
        ]
        |> map Okay


decodeNpc : Url -> Decoder Site
decodeNpc url =
    decode (always (decodeNpcSite url))
        |> required "type" (exclusively "npc" string)
        |> required "npc" string
        |> required "meta" value
        |> required "nip" Decoders.Network.nip
        |> optional "password" (maybe string) Nothing
        |> resolve


decodeNpcSite :
    Url
    -> String
    -> Value
    -> NIP
    -> Maybe String
    -> Decoder Site
decodeNpcSite url npc meta nip password =
    let
        decodeType =
            case npc of
                "home" ->
                    succeed Home

                "profile" ->
                    succeed Profile

                "whois" ->
                    succeed Whois

                "download_center" ->
                    map DownloadCenter decodeDownloadCenterMeta

                "isp" ->
                    succeed ISP

                "bank" ->
                    map Bank decodeBankMeta

                "store" ->
                    succeed Store

                "btc" ->
                    succeed BTC

                "fbi" ->
                    succeed FBI

                "news" ->
                    succeed News

                "bithub" ->
                    succeed Bithub

                "missions" ->
                    succeed MissionCenter

                name ->
                    fail ("Unknown web page type `" ++ name ++ "'")

        toSite type_ =
            { type_ = type_
            , url = url
            , nip = nip
            , password = password
            }
    in
        case decodeValue decodeType meta of
            Ok type_ ->
                succeed <| toSite type_

            Err err ->
                fail err


decodeBankMeta : Decoder BankMetadata
decodeBankMeta =
    let
        bankCoords =
            let
                matchCoords lst =
                    case lst of
                        [ a, b ] ->
                            succeed ( a, b )

                        _ ->
                            fail "Invalid coords format"
            in
                list float
                    |> andThen matchCoords
    in
        decode BankMetadata
            |> required "title" string
            |> required "location" bankCoords


decodeDownloadCenterMeta : Decoder DownloadCenterMetadata
decodeDownloadCenterMeta =
    decode DownloadCenterMetadata
        |> required "title" string


decodeVpc : Url -> Decoder Site
decodeVpc url =
    decode (always (decodeVpcSite url))
        |> required "type" (exclusively "vpc" string)
        |> required "meta" value
        |> required "nip" Decoders.Network.nip
        |> optional "password" (maybe string) Nothing
        |> resolve


decodeVpcSite :
    Url
    -> Value
    -> NIP
    -> Maybe String
    -> Decoder Site
decodeVpcSite url meta nip password =
    let
        decodeWeb =
            decode (WebserverMetadata >> Webserver)
                |> required "custom" string

        decodeNoWeb =
            succeed NoWebserver

        decodeType =
            oneOf [ decodeWeb, decodeNoWeb ]

        toSite type_ =
            { type_ = type_
            , url = url
            , nip = nip
            , password = password
            }
    in
        case decodeValue decodeType meta of
            Ok type_ ->
                succeed <| toSite type_

            Err err ->
                fail err
