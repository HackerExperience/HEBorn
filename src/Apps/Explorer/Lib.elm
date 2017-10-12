module Apps.Explorer.Lib exposing (..)

import Game.Servers.Filesystem.Shared as Filesystem exposing (..)


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


fileSizeToFloat : FileSize -> Float
fileSizeToFloat fsize =
    fsize
        |> Maybe.map toFloat
        |> Maybe.withDefault 0


hasModules : Mime -> Bool
hasModules mime =
    case mime of
        Text ->
            False

        CryptoKey ->
            False

        _ ->
            True
