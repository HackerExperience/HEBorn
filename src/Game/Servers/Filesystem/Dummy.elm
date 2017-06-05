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
        )


dummyFS : Filesystem
dummyFS =
    Dict.fromList
        [ ( "/"
          , [ Folder (FolderData "" "bin" "/bin")
            , Folder (FolderData "" "lib" "/lib")
            , Folder (FolderData "" "share" "/share")
            , Folder (FolderData "" "etc" "/etc")
            , Folder (FolderData "" "home" "/home")
            ]
          )
        , ( "/home"
          , [ Folder (FolderData "" "me" "/home/me") ]
          )
        , ( "/home/me"
          , [ StdFile
                (StdFileData
                    ""
                    "Test"
                    "fwl"
                    (FileVersionNumber 2)
                    (FileSizeNumber 900000)
                    "/home/me/Test.fwl"
                    [ (FileModule "Active" 1) ]
                )
            ]
          )
        ]
