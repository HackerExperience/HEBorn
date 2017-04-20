module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String
import Game.Servers.Filesystem.ModelTest as FilesystemModel
import Apps.Explorer.ModelTest as ExplorerModel


all : Test
all =
    describe "heborn"
        [ FilesystemModel.all
        , ExplorerModel.all
        ]
