module Helper.Filesystem exposing (..)

import Game.Servers.Filesystem.Models exposing (..)
import Game.Servers.Filesystem.Shared exposing (..)


{-| Like "mkdir -p", add folders recursively for given path.
-}
mkdirp : Path -> Model -> Model
mkdirp path model =
    let
        reducer folder ( path, list ) =
            ( appendPath folder path
            , ( path, folder ) :: list
            )
    in
        path
            |> List.drop 1
            |> List.foldl reducer ( [ "" ], [] )
            |> Tuple.second
            |> List.reverse
            |> List.foldl (uncurry insertFolder) model
