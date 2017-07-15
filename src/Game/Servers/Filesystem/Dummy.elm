module Game.Servers.Filesystem.Dummy exposing (dummy)

import Game.Servers.Filesystem.Shared exposing (..)
import Game.Servers.Filesystem.Models exposing (..)


dummy : Filesystem
dummy =
    initialFilesystem
        |> addEntry (FolderEntry { id = "001", name = "home", parent = RootRef })
        |> addEntry (FolderEntry { id = "002", name = "root", parent = NodeRef "001" })
        |> addEntry
            (FileEntry
                { id = "003"
                , name = "Firewall"
                , parent = NodeRef "002"
                , size = Just 900000
                , version = Just 2
                , modules =
                    [ Module "Active" 1
                    , Module "Passive" 2
                    ]
                , extension = "fwl"
                }
            )
        |> addEntry
            (FileEntry
                { id = "004"
                , name = "Virus"
                , parent = NodeRef "002"
                , size = Just 752000
                , version = Just 2
                , modules = [ Module "Active" 1 ]
                , extension = "spam"
                }
            )
