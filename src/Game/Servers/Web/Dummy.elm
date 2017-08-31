module Game.Servers.Web.Dummy exposing (..)

import Game.Servers.Web.Types exposing (..)


dummyTunnel : List String -> Type
dummyTunnel req =
    case req of
        "profile" :: _ ->
            Profile

        "directory" :: _ ->
            Directory

        "baixaki" :: _ ->
            DownloadCenter

        "meuisp" :: _ ->
            ISP

        "fbi" :: _ ->
            FBI

        "lulapresoamanha" :: _ ->
            News

        "headquarters" :: _ ->
            MissionCenter

        "hacking" :: _ ->
            NoWebserver

        _ ->
            Unknown
