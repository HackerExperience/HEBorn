module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String
import Game.Software.ModelTest
import Apps.Explorer.ModelTest


all : Test
all =
    describe "heborn"
        [ Game.Software.ModelTest.all
        , Apps.Explorer.ModelTest.all
        ]
