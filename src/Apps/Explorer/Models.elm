module Apps.Explorer.Models exposing (..)

import Utils exposing (andThenWithDefault)
import Game.Servers.Models
    exposing
        ( ServerID
        , getFilesystem
        , getServerByID
        , Servers
        )
import Game.Servers.Filesystem.Models
    exposing
        ( FilePath
        , rootPath
        , pathExists
        , File
        , getFilesOnPath
        )
import Apps.Explorer.Menu.Models as Menu


type alias Explorer =
    { path : FilePath }


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
        andThenWithDefault ((++) name) name posfix


icon : String
icon =
    "explorer"


initialExplorer : Explorer
initialExplorer =
    { path = rootPath
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


changePath :
    FilePath
    -> Explorer
    -> Servers
    -> Explorer
changePath path explorer servers =
    let
        server =
            getServerByID servers "localhost"

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


resolvePath : Servers -> FilePath -> List File
resolvePath servers path =
    let
        server =
            getServerByID servers "localhost"

        filesystem =
            getFilesystem server
    in
        andThenWithDefault
            (getFilesOnPath path)
            []
            filesystem
