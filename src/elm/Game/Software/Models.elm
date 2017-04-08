module Game.Software.Models exposing ( SoftwareModel, initialSoftwareModel
                                     , Filesystem, initialFilesystem
                                     , File(..)
                                     , FileID, FilePath, FileSize(..), FileVersion(..)
                                     , addFile, removeFile
                                     , getFilePath, getFileName, getFilesOnPath
                                     , pathExists, rootPath
                                     , listFilesystem)


import Dict
import Game.Shared exposing (ID)


type alias FileID =
    ID


type alias FilePath =
    String


type FileVersion
    = FileVersionNumber Int
    | NoVersion


type FileSize
    = FileSizeNumber Int
    | NoSize


type alias RegularFileData =
    { id : FileID
    , name : String
    , extension : String
    , version : FileVersion
    , size : FileSize
    , path : FilePath}


type alias FolderData =
    { id : FileID
    , name : String
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


addFile : SoftwareModel -> File -> SoftwareModel
addFile model file =
    let
        path = getFilePath file
        filesOnPath = getFilesOnPath model path
        newFiles = filesOnPath ++ [file]
    in
        {model | filesystem = (Dict.insert path newFiles model.filesystem)}


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


removeFile : SoftwareModel -> File -> SoftwareModel
removeFile model file =
    let
        path = getFilePath file
        name = getFileName file
        filesOnPath = getFilesOnPath model path
        newFiles = List.filter (\x -> (getFileName x) /= name) filesOnPath
    in
        {model | filesystem = (Dict.insert path newFiles model.filesystem)}


listFilesystem : SoftwareModel -> String
listFilesystem model =
    toString model.filesystem


initialFilesystem : Filesystem
initialFilesystem =
    Dict.empty


initialSoftwareModel : SoftwareModel
initialSoftwareModel =
    {filesystem = initialFilesystem}


rootPath : FilePath
rootPath =
    "/"
