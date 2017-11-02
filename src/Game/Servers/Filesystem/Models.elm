module Game.Servers.Filesystem.Models
    exposing
        ( Model
        , Files
        , Folders
        , Id
        , File
        , Path
        , Name
        , Extension
        , Version
        , Size
        , Entry(..)
        , FileEntry
        , Type(..)
        , CrackerModules
        , FirewallModules
        , ExploitModules
        , HasherModules
        , LogForgerModules
        , LogRecoverModules
        , EncryptorModules
        , DecryptorModules
        , AnyMapModules
        , initialModel
        , insertFile
        , insertFolder
        , deleteFile
        , deleteFolder
        , moveFile
        , renameFile
        , toPath
        , joinPath
        , pathBase
        , parentPath
        , appendPath
        , concatPath
        , list
        , scan
        , getFile
        , getFolder
        , getName
        , setName
        , getExtension
        , getPath
        , setPath
        , getFullpath
        , getSize
        , getType
        , getMeanVersion
        , getModuleVersion
        , getEntryName
        , isValidFilename
        , isFile
        , isFolder
        , isFolderEntry
        , hasModules
        , toId
        , toFile
        , toFileEntry
        )

import Dict exposing (Dict)
import Utils.List as List


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


type alias Id =
    String


type alias File =
    { name : Name
    , extension : Extension
    , path : Path
    , size : Size
    , type_ : Type
    }


type Entry
    = FileEntry Id File
    | FolderEntry Path String


type alias Path =
    List Name


type alias Name =
    String


type alias Extension =
    String


type alias Size =
    Int


{-| Use this type for passing a `File` around with its `Id`.
-}
type alias FileEntry =
    ( Id, File )


{-| Note: a file version is computed when requested.
-}
type alias Version =
    Float


{-| Possible file types, software files include modules.
-}
type Type
    = Text
    | CryptoKey
    | Cracker CrackerModules
    | Firewall FirewallModules
    | Exploit ExploitModules
    | Hasher HasherModules
    | LogForger LogForgerModules
    | LogRecover LogRecoverModules
    | Encryptor EncryptorModules
    | Decryptor DecryptorModules
    | AnyMap AnyMapModules


{-| The base for a module is a version, additional data may be included.
-}
type alias Module a =
    { a | version : Float }


{-| A simple module includes nothing but the version.
-}
type alias SimpleModule =
    Module {}


type alias CrackerModules =
    { bruteForce : SimpleModule
    , overFlow : SimpleModule
    }


type alias FirewallModules =
    { active : SimpleModule
    , passive : SimpleModule
    }


type alias ExploitModules =
    { ftp : SimpleModule
    , ssh : SimpleModule
    }


type alias HasherModules =
    { password : SimpleModule
    }


type alias LogForgerModules =
    { create : SimpleModule
    , edit : SimpleModule
    }


type alias LogRecoverModules =
    { recover : SimpleModule
    }


type alias EncryptorModules =
    { file : SimpleModule
    , log : SimpleModule
    , connection : SimpleModule
    , process : SimpleModule
    }


type alias DecryptorModules =
    { file : SimpleModule
    , log : SimpleModule
    , connection : SimpleModule
    , process : SimpleModule
    }


type alias AnyMapModules =
    { geo : SimpleModule
    , net : SimpleModule
    }



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

        directoryExists =
            isFolder path model

        noFileExists =
            file
                |> getFullpath
                |> flip isFile model
                |> not
    in
        if directoryExists && noFileExists then
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
    case scan path model of
        [ _ ] ->
            { model | folders = Dict.remove (joinPath path) folders }

        _ ->
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



-- path operations


toPath : String -> Path
toPath =
    String.split "/"


joinPath : Path -> String
joinPath =
    String.join "/"


pathBase : Path -> Name
pathBase path =
    case List.head <| List.reverse path of
        Just a ->
            a

        Nothing ->
            ""


parentPath : Path -> Path
parentPath =
    List.dropRight 1


appendPath : Name -> Path -> Path
appendPath name path =
    -- add root folder if not present
    case List.head path of
        Just "" ->
            path ++ [ name ]

        _ ->
            "" :: (path ++ [ name ])


concatPath : List Path -> Path
concatPath =
    List.concat



-- listing path contents


{-| List direct entries of given folder.
Time is O(n*2) of filesystem and O(n) of folder childs.
-}
list : Path -> Model -> List Entry
list path model =
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

        reducer location files entries =
            if (contains location) then
                files
                    |> List.filterMap (get >> Maybe.andThen (uncurry filter))
                    |> (::) (FolderEntry (toPath location) name)
                    |> flip List.append entries
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


getName : File -> Name
getName =
    .name


setName : String -> File -> File
setName name file =
    { file | name = name }


getExtension : File -> Extension
getExtension =
    .extension


getPath : File -> Path
getPath =
    .path


setPath : Path -> File -> File
setPath path file =
    { file | path = path }


getFullpath : File -> Path
getFullpath file =
    file
        |> getPath
        |> appendPath (getName file)


getSize : File -> Size
getSize =
    .size


getType : File -> Type
getType =
    .type_


getMeanVersion : File -> Maybe Version
getMeanVersion file =
    case getModuleVersions file of
        Just versions ->
            versions
                |> List.foldl (+) 0.0
                |> flip (/) (toFloat <| List.length versions)
                |> Just

        Nothing ->
            Nothing


getModuleVersion : Module a -> Version
getModuleVersion =
    .version


getEntryName : Entry -> Name
getEntryName entry =
    case entry of
        FolderEntry _ name ->
            name

        FileEntry _ file ->
            getName file



-- checking operations


isValidFilename : String -> Bool
isValidFilename filename =
    -- TODO: Add special characters & entire name validation
    if String.length filename > 0 then
        False
    else if String.length filename < 255 then
        False
    else
        True


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


isFolderEntry : Entry -> Bool
isFolderEntry entry =
    case entry of
        FolderEntry _ _ ->
            True

        FileEntry _ _ ->
            False


hasModules : File -> Bool
hasModules file =
    case getType file of
        Text ->
            False

        CryptoKey ->
            False

        _ ->
            True



-- entry convertion


toId : FileEntry -> Id
toId =
    Tuple.first


toFile : FileEntry -> File
toFile =
    Tuple.second


toFileEntry : Entry -> Maybe FileEntry
toFileEntry entry =
    case entry of
        FolderEntry _ _ ->
            Nothing

        FileEntry id file ->
            Just ( id, file )



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


getModuleVersions : File -> Maybe (List Version)
getModuleVersions file =
    case getType file of
        Text ->
            Nothing

        CryptoKey ->
            Nothing

        Cracker { bruteForce, overFlow } ->
            Just [ bruteForce.version, overFlow.version ]

        Firewall { active, passive } ->
            Just [ active.version, passive.version ]

        Exploit { ftp, ssh } ->
            Just [ ftp.version, ssh.version ]

        Hasher { password } ->
            Just [ password.version ]

        LogForger { create, edit } ->
            Just [ create.version, edit.version ]

        LogRecover { recover } ->
            Just [ recover.version ]

        Encryptor { file, log, connection, process } ->
            Just
                [ file.version
                , log.version
                , connection.version
                , process.version
                ]

        Decryptor { file, log, connection, process } ->
            Just
                [ file.version
                , log.version
                , connection.version
                , process.version
                ]

        AnyMap { geo, net } ->
            Just [ geo.version, net.version ]
