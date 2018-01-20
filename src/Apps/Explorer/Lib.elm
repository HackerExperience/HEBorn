module Apps.Explorer.Lib exposing (..)

import Game.Servers.Filesystem.Shared as Filesystem


-- FILESYSTEM


fileSizeToFloat : Filesystem.Size -> Float
fileSizeToFloat =
    toFloat


hasModules : Filesystem.Type -> Bool
hasModules type_ =
    case type_ of
        Filesystem.Text ->
            False

        Filesystem.CryptoKey ->
            False

        _ ->
            True
