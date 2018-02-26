module Game.Servers.Requests.Browse
    exposing
        ( Data
        , Error(..)
        , browseRequest
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
import Requests.Requests as Requests exposing (report_)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Utils.Json.Decode exposing (message)
import Decoders.Network
import Decoders.Filesystem
import Game.Meta.Types.Network.Site as Site exposing (Site)
import Game.Meta.Types.Network as Network
import Game.Servers.Shared exposing (CId)


type alias Data =
    Result Error Site


type Error
    = PageNotFound Site.Url
    | ConnectionError Site.Url


browseRequest : Site.Url -> Network.ID -> CId -> FlagsSource a -> Cmd Data
browseRequest url nid cid flagsSrc =
    flagsSrc
        |> Requests.request_ (Topics.browse cid) (encoder nid url)
        |> Cmd.map (uncurry <| receiver flagsSrc url)



-- internals


encoder : Network.ID -> Site.Url -> Value
encoder nid url =
    Encode.object
        [ ( "network_id", Encode.string nid )
        , ( "address", Encode.string url )
        ]


receiver : FlagsSource a -> Site.Url -> Code -> Value -> Data
receiver flagsSrc url code value =
    case code of
        OkCode ->
            value
                |> decodeValue (site url)
                |> report_ "Servers.Browse" code flagsSrc
                |> Result.mapError (always <| ConnectionError url)

        _ ->
            value
                |> decodeValue (errorMessage url)
                |> report_ "Servers.Browse" code flagsSrc
                |> Result.mapError (always <| ConnectionError url)
                |> Result.andThen Err


site : Site.Url -> Decoder Site
site url =
    andThen (siteByType url) (field "content" type_)


type_ : Decoder Site.Type
type_ =
    flip andThen (field "type" string) <|
        \str ->
            case str of
                "home" ->
                    succeed Site.Home

                "profile" ->
                    succeed Site.Profile

                "vpc" ->
                    web

                "npc_whois" ->
                    succeed Site.Whois

                "npc_download_center" ->
                    downloadCenter

                "npc_story_char" ->
                    web

                "npc_isp" ->
                    succeed Site.ISP

                "npc_bank" ->
                    bank

                "npc_store" ->
                    succeed Site.Store

                "npc_btc" ->
                    succeed Site.BTC

                "npc_fbi" ->
                    succeed Site.FBI

                "npc_news" ->
                    succeed Site.News

                "npc_bithub" ->
                    succeed Site.Bithub

                "npc_missions" ->
                    succeed Site.MissionCenter

                _ ->
                    fail "Unknown web page type"


siteByType : Site.Url -> Site.Type -> Decoder Site
siteByType url type_ =
    decode (Site url type_)
        |> required "meta" meta


meta : Decoder Site.Meta
meta =
    decode Site.Meta
        |> optional "password" (nullable string) Nothing
        |> required "nip" Decoders.Network.nipTuple
        |> optional "public" (list Decoders.Filesystem.fileEntry) []


web : Decoder Site.Type
web =
    decode Site.WebserverContent
        |> hardcoded "TODO"
        |> map Site.Webserver


bank : Decoder Site.Type
bank =
    decode Site.BankContent
        |> required "title" string
        |> required "nip" Decoders.Network.nipTuple
        |> map Site.Bank


downloadCenter : Decoder Site.Type
downloadCenter =
    decode Site.DownloadCenterContent
        |> required "title" string
        |> map Site.DownloadCenter


errorMessage : Site.Url -> Decoder Error
errorMessage url =
    message <|
        \str ->
            case str of
                "web_not_found" ->
                    succeed <| PageNotFound url

                _ ->
                    fail "Unknown dns request error message"
