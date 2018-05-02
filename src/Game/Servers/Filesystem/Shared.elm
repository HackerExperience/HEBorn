module Game.Servers.Filesystem.Shared
    exposing
        ( Id
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
        , SpywareModules
        , toPath
        , joinPath
        , pathBase
        , parentPath
        , appendPath
        , concatPath
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
        , isFolderEntry
        , hasModules
        , toId
        , toFile
        , toFileEntry
        )

import Utils.List as List


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
    | Spyware SpywareModules


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


type alias SpywareModules =
    { spy : SimpleModule
    }



-- path operations


toPath : String -> Path
toPath path =
    case String.split "/" path of
        "" :: path ->
            "" :: path

        path ->
            "" :: path


joinPath : Path -> String
joinPath path =
    case path of
        "" :: _ ->
            String.join "/" path

        _ ->
            "/" ++ (String.join "/" path)


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
    path ++ [ name ]


concatPath : List Path -> Path
concatPath =
    List.concat



-- getters/setters


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

        Spyware { spy } ->
            Just [ spy.version ]
