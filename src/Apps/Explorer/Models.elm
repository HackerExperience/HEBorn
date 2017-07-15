module Apps.Explorer.Models exposing (..)

import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Filesystem.Models as Filesystem
import Apps.Explorer.Menu.Models as Menu
import Apps.Explorer.Lib exposing (locationToString)


type EditingStatus
    = NotEditing
    | CreatingFile String
    | CreatingPath String
    | Moving Filesystem.FileID
    | Renaming Filesystem.FileID String


type alias Explorer =
    { path : Filesystem.Location
    , editing : EditingStatus
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
            locationToString app.path

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
    { path = []
    , editing = NotEditing
    }


initialModel : Model
initialModel =
    { app = initialExplorer
    , menu = Menu.initialMenu
    }


getPath : Explorer -> Filesystem.Location
getPath explorer =
    explorer.path


setPath : Explorer -> Filesystem.Location -> Explorer
setPath explorer loc =
    { explorer
        | path = loc
        , editing =
            case explorer.editing of
                Moving _ ->
                    explorer.editing

                _ ->
                    NotEditing
    }


changePath :
    Filesystem.Location
    -> Filesystem.Filesystem
    -> Explorer
    -> Explorer
changePath path filesystem explorer =
    if Filesystem.isLocationValid path filesystem then
        setPath explorer path
    else
        explorer


resolvePath : Server -> Filesystem.Location -> List Filesystem.Entry
resolvePath server path =
    Filesystem.findChildren path (Servers.getFilesystem server)


setEditing : EditingStatus -> Explorer -> Explorer
setEditing val src =
    { src | editing = val }
