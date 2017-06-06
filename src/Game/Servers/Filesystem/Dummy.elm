module Game.Servers.Filesystem.Dummy exposing (dummyFS)

import Dict
import Game.Servers.Filesystem.Models
    exposing
        ( Filesystem
        , File(..)
        , FileVersion(..)
        , FolderData
        , StdFileData
        , FileModule
        , FileSize(..)
        , initialFilesystem
        , addFile
        )


dummyFS : Filesystem
dummyFS =
    let
        unhackedFS =
            initialFilesystem
                |> addFile (Folder (FolderData "001" "home" "/"))
                |> addFile (Folder (FolderData "002" "root" "/home"))
                |> addFile
                    (StdFile
                        (StdFileData
                            "003"
                            "Test"
                            "fwl"
                            (FileVersionNumber 2)
                            (FileSizeNumber 900000)
                            "/home/root"
                            [ (FileModule "Active" 1) ]
                        )
                    )
    in
        { unhackedFS
            | pathIndex = Dict.insert ("/favorites") [ "002" ] unhackedFS.pathIndex
        }
