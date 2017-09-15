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
        , fail
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
import Game.Web.Types exposing (..)
import Game.Web.Messages exposing (..)
import Game.Web.DNS exposing (..)


request : String -> String -> Requester -> ConfigSource a -> Cmd Msg
request serverId url requester =
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
                (errorMessage url)
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


encoder : String -> Value
encoder url =
    Encode.object
        [ ( "url", Encode.string url )
        ]


decoder : Url -> Decoder Response
decoder url =
    field "type" string
        |> andThen (matchSite url)


okayPack : Url -> Type -> Decoder Response
okayPack url type_ =
    { type_ = type_, url = url }
        |> Okay
        |> succeed


matchSite : Url -> String -> Decoder Response
matchSite url typeStr =
    case typeStr of
        "home" ->
            okayPack url Home

        "web" ->
            webServer url

        "noweb" ->
            noWebServer url

        "profile" ->
            okayPack url Profile

        "whois" ->
            okayPack url Whois

        "downcenter" ->
            okayPack url DownloadCenter

        "isp" ->
            okayPack url ISP

        "bank" ->
            bank url

        "store" ->
            okayPack url Store

        "btc" ->
            okayPack url BTC

        "fbi" ->
            okayPack url FBI

        "news" ->
            okayPack url News

        "bithub" ->
            okayPack url Bithub

        "missions" ->
            okayPack url MissionCenter

        _ ->
            fail "Unknown web page type"


webServer : Url -> Decoder Response
webServer url =
    decode WebserverMetadata
        |> optional "password" (maybe string) Nothing
        |> required "custom" string
        |> andThen (Webserver >> okayPack url)


noWebServer : Url -> Decoder Response
noWebServer url =
    decode NoWebserverMetadata
        |> optional "password" (maybe string) Nothing
        |> andThen (NoWebserver >> okayPack url)


bank : Url -> Decoder Response
bank url =
    decode BankMetadata
        |> required "title" string
        |> required "location" bankCoords
        |> andThen (Bank >> okayPack url)


bankCoords : Decoder ( Float, Float )
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
