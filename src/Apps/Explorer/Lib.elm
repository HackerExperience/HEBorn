module Apps.Explorer.Lib exposing (..)

import Game.Servers.Filesystem.Shared as Filesystem exposing (Location, FileSize, ModuleName, rootSymbol, pathSeparator)


-- PATH


locationToString : Location -> String
locationToString loc =
    let
        join =
            String.join pathSeparator
    in
        rootSymbol ++ (join loc)


dropRight : Int -> List a -> List a
dropRight num list =
    (List.take ((List.length list) - num) list)


locationGoUp : Location -> Location
locationGoUp loc =
    dropRight 1 loc



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
    fsize
        |> Maybe.map toFloat
        |> Maybe.withDefault 0
