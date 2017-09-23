module Game.Web.Types exposing (..)

import Game.Network.Types exposing (NIP)


type alias Url =
    String


type alias Site =
    { url : String
    , type_ : Type
    , meta : Meta
    }


type alias Meta =
    { password : Maybe String
    , nip : NIP
    }


type Type
    = NotFound
    | Home
    | Webserver WebserverContent
    | NoWebserver
    | Profile
    | Whois
    | DownloadCenter DownloadCenterContent
    | ISP
    | Bank BankContent
    | Store
    | BTC
    | FBI
    | News
    | Bithub
    | MissionCenter


type alias WebserverContent =
    { custom : String }


type alias BankContent =
    { title : String
    }


type alias DownloadCenterContent =
    { title : String
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
