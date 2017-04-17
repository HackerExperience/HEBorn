module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String

import Game.Software.ModelTest


all : Test
all =
    describe "heborn"
        [ Game.Software.ModelTest.all ]
