module Game.Servers.Filesystem.Models
    exposing
        ( Model
        , Files
        , Folders
        , initialModel
        , insertFile
        , insertFolder
        , deleteFile
        , deleteFolder
        , moveFile
        , renameFile
        , list
        , scan
        , getFile
        , getFolder
        , isFile
        , isFolder
        )

import Dict exposing (Dict)
import Game.Servers.Filesystem.Shared exposing (..)


{-| Two dicts, one mapping ids to files, another mapping paths to ids.
This is not the fastest or simplest way for doing it, but this method
helps keeping types simpler.
-}
type alias Model =
    { files : Files
    , folders : Folders
    }


type alias Files =
    Dict Id File


type alias Folders =
    Dict String (List Id)



-- crud


initialModel : Model
initialModel =
    { files = Dict.empty
    , folders = Dict.fromList [ ( "", [] ) ]
    }


{-| Inserting a file requires its `Id`, the insertion
will occur in the file's path.
-}
insertFile : Id -> File -> Model -> Model
insertFile id file ({ files, folders } as model) =
    let
        path =
            getPath file

        noFileExists =
            file
                |> getFullpath
                |> flip isFile model
                |> not
    in
        if noFileExists then
            let
                model_ =
                    deleteFile id model
            in
                { model_
                    | files = Dict.insert id file files
                    , folders = insertInFolder id path folders
                }
        else
            model


{-| Inserting a folder requires its `Path`.
-}
insertFolder : Path -> Name -> Model -> Model
insertFolder path name ({ folders } as model) =
    if isFolder path model then
        let
            fullpath =
                path
                    |> appendPath name
                    |> joinPath
        in
            case Dict.get fullpath folders of
                Just _ ->
                    model

                Nothing ->
                    { model | folders = Dict.insert fullpath [] folders }
    else
        model


{-| Deleting a File is O(n) of the folder size.
-}
deleteFile : Id -> Model -> Model
deleteFile id ({ files, folders } as model) =
    case Dict.get id files of
        Just file ->
            { model
                | files = Dict.remove id files
                , folders = removeFromFolder id file.path folders
            }

        Nothing ->
            model


{-| Deletes a folder by path, also removes its childs.
Time is O(n*2) of filesystem and O(n) of deleted entries.
-}
deleteFolder : Path -> Model -> Model
deleteFolder path ({ folders } as model) =
    if List.isEmpty <| scan path model then
        { model | folders = Dict.remove (joinPath path) folders }
    else
        model


{-| Moves a File using its Id and Path.
Time is O(n*2) of filesystem and O(n) of path entries.
-}
moveFile : Id -> Path -> Model -> Model
moveFile id path ({ files, folders } as model) =
    case Dict.get id files of
        Just file ->
            let
                file_ =
                    { file | path = path }

                files_ =
                    Dict.insert id file_ files

                folders_ =
                    folders
                        |> removeFromFolder id file.path
                        |> insertInFolder id file_.path
            in
                { model | files = files_, folders = folders_ }

        Nothing ->
            model


renameFile : Id -> Name -> Model -> Model
renameFile id name model =
    case getFile id model of
        Just file ->
            insertFile id (setName name file) model

        Nothing ->
            model



-- listing path contents


{-| List direct entries of given folder.
Time is O(n*2) of filesystem and O(n) of folder childs.
-}
list : Path -> Model -> List Entry
list path model =
    -- TODO: add nested folder support
    let
        drop =
            String.dropLeft (String.length (joinPath path))

        split =
            String.split "/"

        filter item =
            case item of
                FileEntry _ file ->
                    file.path == path

                FolderEntry path _ ->
                    let
                        isEmpty =
                            model
                                |> getFolder path
                                |> Maybe.map List.isEmpty
                                |> Maybe.withDefault True
                    in
                        if isEmpty then
                            True
                        else
                            path
                                |> joinPath
                                |> drop
                                |> split
                                |> List.length
                                |> ((==) 1)
    in
        model
            |> scan path
            |> List.filter filter


{-| List direct entries of given folder.
Time is O(n*2) of filesystem.
-}
scan : Path -> Model -> List Entry
scan path model =
    let
        location =
            joinPath path

        contains =
            String.contains location

        get id =
            case getFile id model of
                Just file ->
                    Just ( id, file )

                Nothing ->
                    Nothing

        filter id file =
            if (contains (joinPath file.path)) then
                Just <| FileEntry id file
            else
                Nothing

        path_ =
            parentPath path

        name =
            path
                |> List.reverse
                |> List.head
                |> Maybe.withDefault ""

        reducer current files entries =
            if (contains current) then
                let
                    entries1 =
                        List.filterMap
                            (get >> Maybe.andThen (uncurry filter))
                            files

                    entries2 =
                        let
                            myPath =
                                toPath current
                        in
                            if current == location then
                                entries1
                            else
                                myPath
                                    |> pathBase
                                    |> FolderEntry (parentPath myPath)
                                    |> flip (::) entries1
                in
                    List.append entries2 entries
            else
                entries
    in
        Dict.foldl reducer [] model.folders



-- getters/setters


getFile : Id -> Model -> Maybe File
getFile id =
    .files >> Dict.get id


getFolder : Path -> Model -> Maybe (List Id)
getFolder path =
    .folders >> Dict.get (joinPath path)



-- checking operations


isFile : Path -> Model -> Bool
isFile fullpath { files, folders } =
    let
        path =
            parentPath fullpath

        name =
            pathBase fullpath
    in
        folders
            |> Dict.get (joinPath path)
            |> Maybe.withDefault []
            |> List.filter
                (flip Dict.get files
                    >> Maybe.map getName
                    >> Maybe.map ((==) name)
                    >> Maybe.withDefault False
                )
            |> List.isEmpty
            |> not


isFolder : Path -> Model -> Bool
isFolder path model =
    case getFolder path model of
        Just _ ->
            True

        Nothing ->
            False



-- internals


removeFromFolder : Id -> Path -> Folders -> Folders
removeFromFolder id path folders =
    let
        location =
            joinPath path
    in
        case Dict.get location folders of
            Just ids ->
                ids
                    |> List.filter ((/=) id)
                    |> flip (Dict.insert location) folders

            Nothing ->
                folders


insertInFolder : Id -> Path -> Folders -> Folders
insertInFolder id path folders =
    let
        location =
            joinPath path
    in
        folders
            |> Dict.get location
            |> Maybe.withDefault []
            |> (::) id
            |> flip (Dict.insert location) folders
