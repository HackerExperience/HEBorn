module Game.Servers.Filesystem.Models
    exposing
        ( Filesystem
        , initialFilesystem
        , File(..)
        , FileID
        , FilePath
        , FileSize(..)
        , FileVersion(..)
        , FileModules
        , FileModule
        , ModuleName
        , ModuleVersion
        , StdFileData
        , FolderData
        , addFile
        , removeFile
        , getFilePath
        , getFileName
        , getFileId
        , getFilesIdOnPath
        , getFilesOnPath
        , pathExists
        , rootPath
        , getFileById
        , moveFile
        , setFilePath
        , pathSeparator
        , getAbsolutePath
        )

import Dict
import Game.Shared exposing (ID)


type alias FileID =
    ID


{-| todo: how about FilePath as a List String?
-}
type alias FilePath =
    String


type FileVersion
    = FileVersionNumber Int
    | NoVersion


type FileSize
    = FileSizeNumber Int
    | NoSize


type alias StdFileData =
    { id : FileID
    , name : String
    , extension : String
    , version : FileVersion
    , size : FileSize
    , path : FilePath
    , modules : FileModules
    }


type alias FileModules =
    List FileModule


type alias FileModule =
    { name : ModuleName
    , version : ModuleVersion
    }


type alias ModuleName =
    String


type alias ModuleVersion =
    Int


type alias FolderData =
    { id : FileID
    , name : String
    , path : FilePath
    }


type File
    = StdFile StdFileData
    | Folder FolderData


type alias Entries =
    Dict.Dict FileID File


type alias PathIndex =
    Dict.Dict FilePath (List FileID)


type alias Filesystem =
    { entries : Entries
    , pathIndex : PathIndex
    }


getFileModules : File -> FileModules
getFileModules file =
    case file of
        StdFile file_ ->
            file_.modules

        Folder folder ->
            []


getFileId : File -> FileID
getFileId file =
    case file of
        StdFile file_ ->
            file_.id

        Folder folder ->
            folder.id


getFilePath : File -> FilePath
getFilePath file =
    case file of
        StdFile file_ ->
            file_.path

        Folder folder ->
            folder.path


setFilePath : FilePath -> File -> File
setFilePath path file =
    case file of
        StdFile file ->
            StdFile { file | path = path }

        Folder folder ->
            Folder { folder | path = path }


getFileName : File -> String
getFileName file =
    case file of
        StdFile file_ ->
            file_.name

        Folder folder ->
            folder.name


addFile : File -> Filesystem -> Filesystem
addFile file filesystem =
    let
        path =
            getFilePath file

        id =
            getFileId file

        files =
            (getFilesIdOnPath path filesystem) ++ [ id ]
    in
        case file of
            StdFile _ ->
                if pathExists path filesystem then
                    { entries = Dict.insert id file filesystem.entries
                    , pathIndex = Dict.insert path files filesystem.pathIndex
                    }
                else
                    filesystem

            -- when adding a new folder we also need to insert a new
            -- path to hold it's files
            Folder _ ->
                let
                    pathIndex =
                        filesystem.pathIndex
                            |> Dict.insert path files
                            |> Dict.insert (getAbsolutePath file) []

                    entries =
                        Dict.insert id file filesystem.entries
                in
                    Filesystem entries pathIndex


getFilesIdOnPath : FilePath -> Filesystem -> List FileID
getFilesIdOnPath path filesystem =
    case Dict.get path filesystem.pathIndex of
        Just files ->
            files

        Nothing ->
            []


getFilesOnPath : FilePath -> Filesystem -> List File
getFilesOnPath path filesystem =
    List.map
        (getFileById filesystem)
        (getFilesIdOnPath path filesystem)


pathExists : FilePath -> Filesystem -> Bool
pathExists path filesystem =
    Dict.member path filesystem.pathIndex


moveFile : FilePath -> File -> Filesystem -> Filesystem
moveFile path file filesystem =
    if (pathExists path filesystem) then
        filesystem
            |> removeFile file
            |> addFile (setFilePath path file)
    else
        filesystem


removeFile : File -> Filesystem -> Filesystem
removeFile file filesystem =
    let
        path =
            getFilePath file

        id =
            getFileId file
    in
        case file of
            StdFile _ ->
                { entries = Dict.remove id filesystem.entries
                , pathIndex =
                    Dict.insert path
                        (filesystem
                            |> getFilesIdOnPath path
                            |> List.filter (\x -> x /= id)
                        )
                        filesystem.pathIndex
                }

            Folder _ ->
                let
                    absPath =
                        getAbsolutePath file
                in
                    -- just like rmdir, it can't remove non-empty folders
                    if List.isEmpty (getFilesIdOnPath absPath filesystem) then
                        { entries = Dict.remove id filesystem.entries
                        , pathIndex = Dict.remove absPath filesystem.pathIndex
                        }
                    else
                        filesystem


getFileById : Filesystem -> FileID -> File
getFileById filesystem fileID =
    case (Dict.get fileID filesystem.entries) of
        Just x ->
            x

        Nothing ->
            Folder (FolderData "invalid" "%invalid" "%")


initialFilesystem : Filesystem
initialFilesystem =
    Filesystem
        (Dict.fromList [ ( "root", Folder (FolderData "root" "/" ".") ) ])
        (Dict.fromList [ ( "/", [] ) ])


rootPath : FilePath
rootPath =
    "/"


pathSeparator : String
pathSeparator =
    "/"


extensionSeparator : String
extensionSeparator =
    "."


getFileNameWithExtension : File -> String
getFileNameWithExtension file =
    case file of
        StdFile prop ->
            -- TODO: add extension with a new function like getFileExtension
            (getFileName file) ++ extensionSeparator ++ prop.extension

        Folder _ ->
            getFileName file


getAbsolutePath : File -> String
getAbsolutePath file =
    let
        name =
            getFileNameWithExtension file

        path =
            getFilePath file
    in
        if (path == "/") then
            path ++ name
        else
            path ++ pathSeparator ++ name
