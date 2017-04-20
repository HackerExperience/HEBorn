module Helper.Filesystem exposing (..)

import Game.Servers.Filesystem.Models exposing (..)


{-| addFileRecursively is a helper because on tests we often want to add a file
in a specific path which *we assume* already exists. On production, we do not assume
this, the path must exists. For a test, however, it's OK to assume. This helper
allow us to have this assumption when adding files. It's usually safe to use
addFileRecursively instead of addFile for tests, unless you want to test exactly
the assumption that the path the file is being added to must exist.
-}
addFileRecursively : Filesystem -> File -> Filesystem
addFileRecursively filesystem file =
    case file of
        Folder _ ->
            addFile filesystem file

        StdFile file_ ->
            let
                path =
                    (getFilePath file)

                -- TODO: this is not recursive, will break once we add nested folders
                folder =
                    Folder { id = "id", name = "name", path = path }

                filesystem_ =
                    addFile filesystem folder
            in
                addFile filesystem_ (StdFile file_)
