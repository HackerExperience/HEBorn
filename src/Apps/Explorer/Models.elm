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


type alias Model =
    { menu : Menu.Model
    , path : Filesystem.Location
    , editing : EditingStatus
    }


name : String
name =
    "Explorer"


title : Model -> String
title model =
    let
        path =
            locationToString model.path

        posfix =
            if String.length path > 12 then
                Just <|
                    ": \""
                        ++ (String.left 5 path)
                        ++ "[...]"
                        ++ (String.right 5 path)
                        ++ "\""
            else if String.length path > 0 then
                Just <| ": \"" ++ path ++ "\""
            else
                Nothing
    in
        posfix
            |> Maybe.map ((++) name)
            |> Maybe.withDefault name


icon : String
icon =
    "explorer"


initialModel : Model
initialModel =
    { menu = Menu.initialMenu
    , path = []
    , editing = NotEditing
    }


getPath : Model -> Filesystem.Location
getPath explorer =
    explorer.path


setPath : Filesystem.Location -> Model -> Model
setPath loc explorer =
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
    -> Model
    -> Model
changePath path filesystem explorer =
    if Filesystem.isLocationValid path filesystem then
        setPath path explorer
    else
        explorer


resolvePath : Server -> Filesystem.Location -> List Filesystem.Entry
resolvePath server path =
    Filesystem.findChildren path (Servers.getFilesystem server)


setEditing : EditingStatus -> Model -> Model
setEditing val src =
    { src | editing = val }
