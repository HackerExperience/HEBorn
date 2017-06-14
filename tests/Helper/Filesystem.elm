module Helper.Filesystem
    exposing
        ( addFileRecursively
        , addPathParents
        )

import Game.Servers.Filesystem.Models exposing (..)


{-| Private function used by a reducer in addPathParents to add folder to given
filesystem.
-}
addFolderReducer : String -> ( Filesystem, String, String ) -> ( Filesystem, String, String )
addFolderReducer folderName ( filesystem, path, baseId ) =
    let
        newBaseId =
            baseId ++ folderName

        folder =
            Folder { id = baseId, name = folderName, path = path }

        filesystem_ =
            addFile folder filesystem

        path_ =
            if path /= "/" then
                path ++ "/" ++ folderName
            else
                path ++ folderName
    in
        ( filesystem_, path_, newBaseId ++ "_" )


{-| Like "mkdir -p", add folders recursively for given path.
-}
addPathParents : String -> String -> Filesystem -> Filesystem
addPathParents path baseId filesystem =
    if pathExists path filesystem then
        filesystem
    else
        let
            ( filesystem_, _, _ ) =
                path
                    |> String.split "/"
                    |> List.tail
                    |> Maybe.withDefault []
                    |> List.foldl addFolderReducer ( filesystem, "/", baseId )
        in
            filesystem_


{-| addFileRecursively is a helper because on tests we often want to add a file
in a specific path which *we assume* already exists. On production, we do not assume
this, the path must exists. For a test, however, it's OK to assume. This helper
allow us to have this assumption when adding files. It's usually safe to use
addFileRecursively instead of addFile for tests, unless you want to test exactly
the assumption that the path the file is being added to must exist.
-}
addFileRecursively : File -> Filesystem -> Filesystem
addFileRecursively file filesystem =
    let
        baseId =
            (getFileId file) ++ "_"
    in
        filesystem
            |> addPathParents (getFilePath file) baseId
            |> addFile file
