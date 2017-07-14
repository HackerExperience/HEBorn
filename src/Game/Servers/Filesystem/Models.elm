module Game.Servers.Filesystem.Models
    exposing
        ( initialFilesystem
        , getEntryId
        , getEntryLocation
        , getEntryBasename
        , getEntryName
        , getEntryLink
        , getEntry
        , findEntry
        , addEntry
        , deleteEntry
        , moveEntry
        , renameFile
        , isDirectory
        , findChildrenIds
        , findChildren
        , isValidFileName
        )

import Dict
import Utils.Dict as Dict
import Utils.List as List
import Game.Servers.Filesystem.Shared exposing (..)


getEntryId : Entry -> FileID
getEntryId entry =
    case entry of
        FileEntry file ->
            file.id

        FolderEntry folder ->
            folder.id


getEntryLocation : Entry -> FilePath
getEntryLocation entry =
    let
        last =
            getEntryName entry

        upList =
            getAncestorsList entry.parent
                |> List.reverse
                |> List.map (getEntryName)
    in
        ( upList, last )


getEntryBasename : Entry -> String
getEntryBasename entry =
    case entry of
        FileEntry file ->
            file.name

        FolderEntry folder ->
            folder.name

pathTreeUpdate

addEntry : Entry -> Filesystem -> Filesystem
addEntry entry filesystem =
    -- TODO: Do nothing when overwriting
    let
        location =
            getEntryLocation entry

        id =
            getEntryId entry

        brotherhood =
            (findChildrenIds location filesystem) ++ [ id ]
    in
        case entry of
            FileEntry _ ->
                if isDirectory location filesystem then
                    { entries = Dict.insert id entry filesystem.entries
                    , root = pathTreeUpdate id.parent brotherhood [] filesystem
                    }
                else
                    filesystem

            -- when adding a new folder we also need to insert a new
            -- path to hold it's files
            FolderEntry _ ->
                let
                    pathIndex =
                        filesystem.pathIndex
                            |> Dict.insert location brotherhood
                            |> Dict.insert (getEntryLink file) []

                    entries =
                        Dict.insert id file filesystem.entries
                in
                    Filesystem entries pathIndex


findChildrenIds : FilePath -> Filesystem -> List FileID
findChildrenIds path filesystem =
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
