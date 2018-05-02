module Apps.Explorer.Models exposing (..)

import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Shared as Servers
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Shared as Filesystem


type EditingStatus
    = NotEditing
    | CreatingFile String
    | CreatingPath String
    | Moving Filesystem.Id
    | MovingDir Filesystem.Path
    | Renaming Filesystem.Id String


type alias Model =
    { storageId : Maybe Servers.StorageId
    , path : Filesystem.Path
    , editing : EditingStatus
    , modal : Maybe ModalAction
    }


type ModalAction
    = ForDownload NIP Filesystem.FileEntry


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
    { storageId = Nothing
    , path = [ "" ]
    , editing = NotEditing
    , modal = Nothing
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


setStorage : Servers.StorageId -> Model -> Model
setStorage storageId model =
    { model | storageId = Just storageId }


getStorage : Server -> Model -> Servers.StorageId
getStorage server model =
    case model.storageId of
        Just storageId ->
            storageId

        Nothing ->
            Servers.getMainStorageId server


getFilesystem : Server -> Model -> Maybe Filesystem.Model
getFilesystem server model =
    server
        |> Servers.getStorage (getStorage server model)
        |> Maybe.map Servers.getFilesystem


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


resolvePath : Filesystem.Path -> Server -> Model -> List Filesystem.Entry
resolvePath path server model =
    model
        |> getFilesystem server
        |> Maybe.map (Filesystem.list path)
        |> Maybe.withDefault []


leaveModal : Model -> Model
leaveModal tab =
    { tab | modal = Nothing }
