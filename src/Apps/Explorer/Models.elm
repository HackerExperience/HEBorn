module Apps.Explorer.Models exposing (..)

import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Filesystem.Models as Filesystem
import Apps.Explorer.Menu.Models as Menu


type EditingStatus
    = NotEditing
    | CreatingFile String
    | CreatingPath String
    | Moving Filesystem.Id
    | MovingDir Filesystem.Path
    | Renaming Filesystem.Id String


type alias Model =
    { menu : Menu.Model
    , path : Filesystem.Path
    , editing : EditingStatus
    }


name : String
name =
    "Explorer"


title : Model -> String
title { path } =
    let
        location =
            Filesystem.joinPath path

        prefix str =
            if str /= location then
                "[...]" ++ str
            else
                str
    in
        location
            |> String.right 10
            |> prefix
            |> (++) (name ++ " - ")


icon : String
icon =
    "explorer"


initialModel : Model
initialModel =
    { menu = Menu.initialMenu
    , path = [ "" ]
    , editing = NotEditing
    }


getPath : Model -> Filesystem.Path
getPath =
    .path


setPath : Filesystem.Path -> Model -> Model
setPath path model =
    { model
        | path = path
        , editing =
            case model.editing of
                Moving _ ->
                    model.editing

                _ ->
                    NotEditing
    }


changePath :
    Filesystem.Path
    -> Filesystem.Model
    -> Model
    -> Model
changePath path fs model =
    if Filesystem.isFolder path fs then
        setPath path model
    else
        model


setEditing : EditingStatus -> Model -> Model
setEditing val src =
    { src | editing = val }


resolvePath : Server -> Filesystem.Path -> List Filesystem.Entry
resolvePath server path =
    Filesystem.list path (Servers.getFilesystem server)
