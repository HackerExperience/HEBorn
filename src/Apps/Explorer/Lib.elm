module Apps.Explorer.Lib exposing (..)

import Game.Servers.Filesystem.Models as Filesystem exposing (FilePath, FileSize(..), ModuleName, rootPath, pathSeparator)


-- PATH


type SmartPath
    = Absolute (List String)
    | Relative (List String)


pathInterpret : FilePath -> SmartPath
pathInterpret path =
    let
        stripRight =
            if (String.endsWith pathSeparator path) then
                (String.dropRight (String.length pathSeparator) path)
            else
                path

        splitPath =
            String.split pathSeparator
    in
        if (String.startsWith rootPath path) then
            Absolute (splitPath (String.dropLeft (String.length rootPath) stripRight))
        else
            Relative (splitPath stripRight)


pathToString : SmartPath -> FilePath
pathToString path =
    let
        join =
            String.join "/"
    in
        case path of
            Absolute entries ->
                "/" ++ (join entries)

            Relative entries ->
                join entries


pathFuckStart : SmartPath -> List String
pathFuckStart path =
    case path of
        Absolute entries ->
            entries

        Relative entries ->
            entries


dropRight : Int -> List a -> List a
dropRight num list =
    (List.take ((List.length list) - num) list)


pathGoUp : SmartPath -> SmartPath
pathGoUp path =
    case path of
        Absolute entries ->
            Absolute (dropRight 1 entries)

        Relative entries ->
            Relative (dropRight 1 entries)



-- FILESYSTEM


type Mime
    = GenericArchive
    | Virus
    | Firewall


type KnownModule
    = Active
    | Passive


extensionInterpret : String -> Mime
extensionInterpret ext =
    case ext of
        "fwl" ->
            Firewall

        "spam" ->
            Virus

        _ ->
            GenericArchive


moduleInterpret : ModuleName -> KnownModule
moduleInterpret name =
    case name of
        "Active" ->
            Active

        _ ->
            Passive


fileSizeToFloat : FileSize -> Float
fileSizeToFloat fsize =
    case fsize of
        FileSizeNumber fsizeInt ->
            toFloat fsizeInt

        NoSize ->
            0
