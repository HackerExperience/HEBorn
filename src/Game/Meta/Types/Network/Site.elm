module Game.Meta.Types.Network.Site exposing (..)

import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Filesystem.Shared as Filesystem


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
    , publicFiles : List Filesystem.FileEntry
    }


type Type
    = NotFound
    | Home
    | Webserver WebserverContent
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
    , nip : NIP
    }


type alias DownloadCenterContent =
    { title : String
    }


getType : Site -> Type
getType site =
    site.type_


getUrl : Site -> Url
getUrl site =
    site.url
