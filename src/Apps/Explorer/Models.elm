module Apps.Explorer.Models exposing (..)

import Dict
import Game.Servers.Models
    exposing
        ( ServerID
        , getFilesystem
        , getServerByID
        )
import Game.Servers.Filesystem.Models as NetModel
    exposing
        ( FilePath
        , rootPath
        , pathExists
        )
import Apps.Explorer.Menu.Models as Menu


type alias FilePath =
    NetModel.FilePath


type alias Explorer =
    { serverID : ServerID
    , path : FilePath
    }


type alias Model =
    { app : Explorer
    , menu : Menu.Model
    }


name : String
name =
    "Explorer"


title : Model -> String
title model =
    "File Explorer"


icon : String
icon =
    "explorer"


initialExplorer : Explorer
initialExplorer =
    { serverID = "invalid"
    , path = rootPath
    }


initialModel : Model
initialModel =
    { app = initialExplorer
    , menu = Menu.initialMenu
    }


getPath : Explorer -> FilePath
getPath explorer =
    explorer.path


setPath : Explorer -> FilePath -> Explorer
setPath explorer path =
    { explorer | path = path }


changePath path explorer game =
    let
        server =
            getServerByID game.servers explorer.serverID

        filesystem =
            getFilesystem server

        explorer_ =
            case filesystem of
                Just fs ->
                    if pathExists path fs then
                        setPath explorer path
                    else
                        explorer

                Nothing ->
                    explorer
    in
        explorer_
