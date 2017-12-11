module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String
import Game.Servers.Filesystem.ModelTest as FilesystemModel
import Game.Servers.Logs.ModelTest as LogsModel
import Game.Servers.Processes.ModelTest as ProcessesModel
import Apps.Browser.ModelTest as BrowserModel
import Apps.Explorer.ModelTest as ExplorerModel
import Game.Account.IntegrationTest as AccountIntegration
import Game.Servers.Processes.IntegrationTest as ProcessIntegration
import Game.Meta.Type.MotherboardTest as MotherboardTest


all : Test
all =
    describe "heborn"
        [ FilesystemModel.all
        , LogsModel.all
        , ProcessesModel.all
        , BrowserModel.all
        , ExplorerModel.all
        , AccountIntegration.all
        , ProcessIntegration.all
        , MotherboardTest.all
        ]
