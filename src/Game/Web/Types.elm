module Game.Web.Types exposing (..)

import Game.Network.Types exposing (NIP)
import Game.Servers.Filesystem.Shared exposing (ForeignFileBox)


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
    , publicFiles : List ForeignFileBox
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



-- This response is located here to avoid a dependency cycle


type Response
    = PageLoaded Site
    | PageNotFound Url
    | ConnectionError Url


getType : Site -> Type
getType site =
    site.type_


getUrl : Site -> Url
getUrl site =
    site.url
