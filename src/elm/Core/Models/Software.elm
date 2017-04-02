module Core.Models.Software exposing (..)

import Dict

import Core.Models.Shared exposing (..)


type alias FilePath =
    String

type FileVersion
    = FileVersionNumber Int
    | NoVersion

type FileSize
    = FileSizeNumber Int
    | NoSize

type alias RegularFileData =
    { name : String
    , extension : String
    , version : FileVersion
    , size : FileSize
    , path : FilePath}

type alias FolderData =
    { name : String
    , path : FilePath}

type File
    = RegularFile RegularFileData
    | RegularFolder FolderData

type alias Filesystem =
    Dict.Dict FilePath (List File)

type alias SoftwareModel =
    { filesystem : Filesystem }


getFilePath : File -> String
getFilePath file =
    let
        path = case file of
            RegularFile file_ ->
                file_.path
            RegularFolder folder ->
                folder.path
    in
        path

getFileName : File -> String
getFileName file =
    let
        name = case file of
            RegularFile file_ ->
                file_.name
            RegularFolder folder ->
                folder.name
    in
        name


addFileToPath : SoftwareModel -> File -> Filesystem
addFileToPath model file =
    let
        path = getFilePath file
        filesOnPath = getFilesOnPath model path
        newFiles = filesOnPath ++ [file]
    in
        Dict.insert path newFiles model.filesystem


getFilesOnPath : SoftwareModel -> FilePath -> List File
getFilesOnPath model path =
    case Dict.get path model.filesystem of
        Just files ->
            files
        Nothing ->
            []


pathExists : SoftwareModel -> FilePath -> Bool
pathExists model path =
    case Dict.get path model.filesystem of
        Just _ ->
            True
        Nothing ->
            False


removeFileFromPath : SoftwareModel -> File -> Filesystem
removeFileFromPath model file =
    let
        path = getFilePath file
        name = getFileName file
        filesOnPath = getFilesOnPath model path
        newFiles = List.filter (\x -> (getFileName x) /= name) filesOnPath
    in
        Dict.insert path newFiles model.filesystem


listFilesystem : SoftwareModel -> String
listFilesystem model =
    toString model.filesystem


initialFilesystem : Filesystem
initialFilesystem =
    Dict.empty


initialSoftwareModel : SoftwareModel
initialSoftwareModel =
    {filesystem = initialFilesystem}

