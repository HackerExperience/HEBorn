module Apps.Explorer.Models exposing (..)

import Dict exposing (Dict)
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Filesystem.Models as Filesystem
import Apps.Explorer.Menu.Models as Menu


type alias Explorer =
    { path : Filesystem.FilePath
    , renaming : Dict Filesystem.FileID String
    }


type alias Model =
    { app : Explorer
    , menu : Menu.Model
    }


name : String
name =
    "Explorer"


title : Model -> String
title ({ app } as model) =
    let
        path =
            app.path

        posfix =
            if (String.length path) > 12 then
                Just
                    (": \""
                        ++ (String.left 5 path)
                        ++ "[...]"
                        ++ (String.right 5 path)
                        ++ "\""
                    )
            else if (String.length path) > 0 then
                Just (": \"" ++ path ++ "\"")
            else
                Nothing
    in
        posfix
            |> Maybe.map ((++) name)
            |> Maybe.withDefault name


icon : String
icon =
    "explorer"


initialExplorer : Explorer
initialExplorer =
    { path = Filesystem.rootPath
    , renaming = Dict.empty
    }


initialModel : Model
initialModel =
    { app = initialExplorer
    , menu = Menu.initialMenu
    }


getPath : Explorer -> Filesystem.FilePath
getPath explorer =
    explorer.path


setPath : Explorer -> Filesystem.FilePath -> Explorer
setPath explorer path =
    { explorer | path = path, renaming = Dict.empty }


changePath :
    Filesystem.FilePath
    -> Filesystem.Filesystem
    -> Explorer
    -> Explorer
changePath path filesystem explorer =
    if Filesystem.pathExists path filesystem then
        setPath explorer path
    else
        explorer


resolvePath : Server -> Filesystem.FilePath -> List Filesystem.File
resolvePath server path =
    Filesystem.getFilesOnPath path (Servers.getFilesystem server)
