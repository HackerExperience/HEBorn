module Game.Software.Models
    exposing
        ( SoftwareModel
        , initialSoftwareModel
        , Filesystem
        , initialFilesystem
        , File(..)
        , FileID
        , FilePath
        , FileSize(..)
        , FileVersion(..)
        , addFile
        , removeFile
        , getFilePath
        , getFileName
        , getFileId
        , getFilesOnPath
        , pathExists
        , rootPath
        , listFilesystem
        , moveFile
        , setFilePath
        , pathSeparator
        )

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


type alias StdFileData =
    { id : FileID
    , name : String
    , extension : String
    , version : FileVersion
    , size : FileSize
    , path : FilePath
    }


type alias FolderData =
    { id : FileID
    , name : String
    , path : FilePath
    }


type File
    = StdFile StdFileData
    | Folder FolderData


type alias Filesystem =
    Dict.Dict FilePath (List File)


type alias SoftwareModel =
    { filesystem : Filesystem }


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


setFilePath : File -> FilePath -> File
setFilePath file path =
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


addFile : SoftwareModel -> File -> SoftwareModel
addFile model file =
    let
        path =
            getFilePath file

        filesOnPath =
            getFilesOnPath model path

        newFiles =
            filesOnPath ++ [ file ]

        filesystem_ =
            case file of
                StdFile _ ->
                    if (pathExists model path) then
                        Dict.insert path newFiles model.filesystem
                    else
                        model.filesystem

                {- Adding a folder is a special case. We need to ensure our model
                   recognizes this new folder as a valid path, so it can store
                   its own StdFiles
                -}
                Folder _ ->
                    let
                        filesystem1 =
                            Dict.insert path newFiles model.filesystem

                        newPath =
                            path ++ pathSeparator ++ (getFileName file)

                        filesystem2 =
                            Dict.insert newPath [] filesystem1
                    in
                        filesystem2
    in
        { model | filesystem = filesystem_ }


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


moveFile : SoftwareModel -> File -> FilePath -> SoftwareModel
moveFile model file path =
    if not (pathExists model path) then
        -- Moving to a non-existing path
        model
    else
        let
            file_ =
                setFilePath file path

            model1 =
                addFile model file_

            model_ =
                removeFile model1 file
        in
            model_


removeFile : SoftwareModel -> File -> SoftwareModel
removeFile model file =
    let
        path =
            getFilePath file

        id =
            getFileId file

        filesOnPath =
            getFilesOnPath model path

        newFiles =
            List.filter (\x -> (getFileId x) /= id) filesOnPath

        filesystem_ =
            case file of
                StdFile _ ->
                    Dict.insert path newFiles model.filesystem

                {- Deleting a folder is a special case. If there are any files
                   inside the folder, it can't be deleted at all. On the other hand,
                   if there are no files, the whole path should be deleted
                -}
                Folder _ ->
                    if List.isEmpty newFiles then
                        Dict.remove path model.filesystem
                    else
                        model.filesystem
    in
        { model | filesystem = filesystem_ }


listFilesystem : SoftwareModel -> String
listFilesystem model =
    toString model.filesystem


initialFilesystem : Filesystem
initialFilesystem =
    Dict.empty


initialSoftwareModel : SoftwareModel
initialSoftwareModel =
    { filesystem = initialFilesystem }


rootPath : FilePath
rootPath =
    "/"


pathSeparator : String
pathSeparator =
    "/"
