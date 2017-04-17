module Gen.Remote exposing (..)

import Dict
import Gen.Utils exposing (..)
import Game.Software.Models exposing (..)


getFiles =
    Dict.insert "path" (RegularFolder { id = "id", name = "name", path = "path" })
