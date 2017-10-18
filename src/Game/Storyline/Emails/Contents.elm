module Game.Storyline.Emails.Contents exposing (..)

import Time exposing (Time)
import Dict exposing (Dict)
import Game.Shared


type Content
    = HelloWorld String


toString : Content -> String
toString content =
    case content of
        HelloWorld some ->
            "hello world! " ++ some
