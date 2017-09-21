module Game.Web.Types exposing (..)

import Game.Network.Types exposing (NIP)


type alias Url =
    String


type alias Site =
    { type_ : Type
    , url : String
    }


type Type
    = NotFound
    | Home
    | Webserver WebserverMetadata
    | NoWebserver NoWebserverMetadata
    | Profile
    | Whois
    | DownloadCenter
    | ISP
    | Bank BankMetadata
    | Store
    | BTC
    | FBI
    | News
    | Bithub
    | MissionCenter


type alias WebserverMetadata =
    { nip : NIP, password : Maybe String, custom : String }


type alias NoWebserverMetadata =
    { nip : NIP, password : Maybe String }


type alias BankMetadata =
    { title : String
    , location : ( Float, Float )
    }


isHackable : Type -> Bool
isHackable t =
    case t of
        NotFound ->
            False

        Profile ->
            False

        _ ->
            True


getType : Site -> Type
getType site =
    site.type_


getUrl : Site -> Url
getUrl site =
    site.url
