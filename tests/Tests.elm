module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String
import Game.Servers.Filesystem.ModelTest as FilesystemModel
import Game.Servers.Logs.ModelTest as LogsModel
import Game.Servers.Processes.LocalModelTest as LocalProcessesModel
import Apps.Browser.ModelTest as BrowserModel
import Apps.Explorer.ModelTest as ExplorerModel


all : Test
all =
    describe "heborn"
        [ FilesystemModel.all
        , LogsModel.all
        , LocalProcessesModel.all
        , BrowserModel.all
        , ExplorerModel.all
        ]
