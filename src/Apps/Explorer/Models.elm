module Apps.Explorer.Models exposing (..)

import Utils exposing (andThenWithDefault)
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
        andThenWithDefault (\posfix -> name ++ posfix) name posfix


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


type alias GameModelCompat a =
    -- FIXME: THIS IS FOR NOT CREATING A DEP-CYCLE WITH GameModel
    { a | servers : Game.Servers.Models.Servers }


changePath :
    FilePath
    -> GameModelCompat a
    -> Explorer
    -> Explorer
changePath path game explorer =
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
