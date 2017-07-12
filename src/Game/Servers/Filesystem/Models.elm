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
        , getFileLocation
        , getFileName
        , getFileId
        , getFilesIdOnPath
        , getFilesOnPath
        , pathExists
        , rootPath
        , getFileById
        , moveFile
        , renameFile
        , pathSeparator
        , getAbsolutePath
        , pathSplit
        , isValidFilename
        , setFilePath
        , setFileName
        )

import Dict
import Utils.Dict as Dict
import Utils.List as List
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


getFileLocation : File -> FilePath
getFileLocation file =
    case file of
        StdFile file_ ->
            file_.path

        Folder folder ->
            folder.path


setFilePath : FilePath -> File -> File
setFilePath path file =
    -- ATTENTION: This doesn't update path index
    case file of
        StdFile file ->
            StdFile { file | path = path }

        Folder folder ->
            Folder { folder | path = path }


setFileName : String -> File -> File
setFileName name file =
    -- ATTENTION: This doesn't update path index
    case file of
        StdFile file ->
            StdFile { file | name = name }

        Folder folder ->
            Folder { folder | name = name }


getFileName : File -> String
getFileName file =
    case file of
        StdFile file_ ->
            file_.name

        Folder folder ->
            folder.name


addFile : File -> Filesystem -> Filesystem
addFile file filesystem =
    -- TODO: Do nothing when overwriting
    let
        path =
            getFileLocation file

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
    List.filterMap
        (getFileById filesystem)
        (getFilesIdOnPath path filesystem)


pathExists : FilePath -> Filesystem -> Bool
pathExists path filesystem =
    Dict.member path filesystem.pathIndex


folderMovementIsValid : FilePath -> File -> Filesystem -> Bool
folderMovementIsValid path file filesystem =
    case file of
        StdFile _ ->
            True

        Folder _ ->
            let
                absPath =
                    getAbsolutePath file

                pathPattrn =
                    absPath ++ pathSeparator

                entries =
                    getFilesOnPath absPath filesystem
            in
                (not <| String.startsWith pathPattrn path)
                    && (List.length entries == 0)


moveFile : FilePath -> File -> Filesystem -> Filesystem
moveFile path file filesystem =
    if
        (getFileLocation file /= path)
            && (pathExists path filesystem)
            && (folderMovementIsValid path file filesystem)
    then
        filesystem
            |> removeFile file
            |> addFile (setFilePath path file)
    else
        filesystem


renameFile : String -> File -> Filesystem -> Filesystem
renameFile name file filesystem =
    case file of
        StdFile _ ->
            if (getFileNameWithExtension file /= name) then
                { filesystem
                    | entries =
                        Dict.insert
                            (getFileId file)
                            (setFileName name file)
                            filesystem.entries
                }
            else
                filesystem

        Folder _ ->
            let
                absPath =
                    getAbsolutePath file

                file_ =
                    setFileName name file

                entries =
                    getFilesOnPath absPath filesystem
            in
                if
                    (getFileName file /= name)
                        && (List.length entries == 0)
                then
                    { filesystem
                        | entries =
                            Dict.insert
                                (getFileId file)
                                file_
                                filesystem.entries
                        , pathIndex =
                            Dict.insert
                                (getAbsolutePath file_)
                                []
                                (Dict.remove absPath filesystem.pathIndex)
                    }
                else
                    filesystem


removeFile : File -> Filesystem -> Filesystem
removeFile file filesystem =
    let
        path =
            getFileLocation file

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
                            |> List.filter ((/=) id)
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
                        , pathIndex =
                            -- Issue: This SUCKS A LOT
                            Dict.filterMap
                                (\k v ->
                                    if (k == absPath) then
                                        Nothing
                                    else
                                        Just <| List.filter ((/=) id) v
                                )
                                filesystem.pathIndex
                        }
                    else
                        filesystem


getFileById : Filesystem -> FileID -> Maybe File
getFileById filesystem fileID =
    Dict.get fileID filesystem.entries


initialFilesystem : Filesystem
initialFilesystem =
    Filesystem
        (Dict.fromList [ ( "root", Folder (FolderData "root" rootPath ".") ) ])
        (Dict.fromList [ ( rootPath, [] ) ])


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
            getFileLocation file
    in
        if (path == pathSeparator) then
            path ++ name
        else
            path ++ pathSeparator ++ name


pathSplit : FilePath -> ( FilePath, Maybe String )
pathSplit src =
    let
        splitten =
            String.split pathSeparator src

        dropLast =
            List.reverse
                >> List.drop 1
                >> List.reverse
                >> String.join pathSeparator
    in
        case ( splitten, List.last splitten ) of
            ( _, Nothing ) ->
                -- IMPOSSIBLE CASE FOR SPLITED STRING
                ( "", Nothing )

            ( [ "" ], Just "" ) ->
                ( rootPath, Nothing )

            ( a, Just "" ) ->
                ( dropLast a, Nothing )

            ( [ "", a ], Just b ) ->
                ( rootPath, Just b )

            ( [ a ], Just b ) ->
                ( rootPath, Just b )

            ( a, Just b ) ->
                ( dropLast a
                , Just b
                )


isValidFilename : String -> Bool
isValidFilename fName =
    -- TODO: Add special characters & entire name validation
    if String.length fName > 0 then
        False
    else if String.length fName < 255 then
        False
    else
        True
