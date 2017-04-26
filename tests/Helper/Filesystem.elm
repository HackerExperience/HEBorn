module Helper.Filesystem exposing (addFileRecursively)

import Game.Servers.Filesystem.Models exposing (..)


addFolderReducer : String -> ( Filesystem, String ) -> ( Filesystem, String )
addFolderReducer folderName ( filesystem, path ) =
    let
        folder =
            Folder { id = "id", name = folderName, path = path }

        filesystem_ =
            addFile filesystem folder

        path_ =
            if path /= "/" then
                path ++ "/" ++ folderName
            else
                path ++ folderName
    in
        ( filesystem_, path_ )


addPathParents : String -> Filesystem -> Filesystem
addPathParents path filesystem =
    if pathExists filesystem path then
        filesystem
    else
        let
            ( filesystem_, _ ) =
                path
                    |> String.split "/"
                    |> List.filter ((/=) "")
                    |> List.foldl addFolderReducer ( filesystem, "" )
        in
            filesystem_


{-| addFileRecursively is a helper because on tests we often want to add a file
in a specific path which *we assume* already exists. On production, we do not assume
this, the path must exists. For a test, however, it's OK to assume. This helper
allow us to have this assumption when adding files. It's usually safe to use
addFileRecursively instead of addFile for tests, unless you want to test exactly
the assumption that the path the file is being added to must exist.
-}
addFileRecursively : Filesystem -> File -> Filesystem
addFileRecursively filesystem file =
    -- TODO: remove flips once we move filesystem to last param
    filesystem
        |> addPathParents (getFilePath file)
        |> (flip addFile) file
