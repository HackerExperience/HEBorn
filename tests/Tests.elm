module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String

import Core.Models.SoftwareTest


all : Test
all =
    describe "heborn"
        [ Core.Models.SoftwareTest.all ]
