module Game.Servers.Web.Types exposing (..)

import Game.Network.Types exposing (NIP)


type alias Site =
    { type_ : Type
    , url : String
    , meta : Maybe Meta
    }


type Type
    = Blank
    | NotFound
    | Unknown
    | Home
    | Webserver
    | NoWebserver
    | Profile
    | Directory
    | DownloadCenter
    | ISP
    | Bank
    | Store
    | BTC
    | FBI
    | News
    | Bithub
    | MissionCenter


type Meta
    = HomeMeta HomeMetadata
    | WebserverMeta WebserverMetadata
    | NoWebserverMeta NoWebserverMetadata
    | ProfileMeta ProfileMetadata
    | DirectoryMeta DirectoryMetadata
    | DownloadCenterMeta DownloadCenterMetadata
    | ISPMeta ISPMetadata
    | BankMeta BankMetadata
    | StoreMeta StoreMetadata
    | BTCMeta BTCMetadata
    | FBIMeta FBIMetadata
    | NewsMeta NewsMetadata
    | BithubMeta BithubMetadata
    | MissionCenterMeta MissionCenterMetadata


type alias HomeMetadata =
    {}


type alias WebserverMetadata =
    { serverId : String, nip : NIP }


type alias NoWebserverMetadata =
    { serverId : String, nip : NIP }


type alias ProfileMetadata =
    {}


type alias DirectoryMetadata =
    {}


type alias DownloadCenterMetadata =
    {}


type alias ISPMetadata =
    {}


type alias BankMetadata =
    {}


type alias StoreMetadata =
    {}


type alias BTCMetadata =
    {}


type alias FBIMetadata =
    {}


type alias NewsMetadata =
    {}


type alias BithubMetadata =
    {}


type alias MissionCenterMetadata =
    {}


getType : Site -> Type
getType site =
    site.type_


getMeta : Site -> Maybe Meta
getMeta site =
    site.meta


getUrl : Site -> String
getUrl site =
    site.url
