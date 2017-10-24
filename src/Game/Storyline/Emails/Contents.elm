module Game.Storyline.Emails.Contents exposing (..)

import Time exposing (Time)
import Dict exposing (Dict)
import Game.Shared


type Content
    = HelloWorld String
    | WelcomePCSetup
    | WelcomeBackThanks


toString : Content -> String
toString content =
    case content of
        HelloWorld some ->
            "hello world! " ++ some

        WelcomePCSetup ->
            "Hello!"

        WelcomeBackThanks ->
            "Thanks"


toId : Content -> String
toId content =
    case content of
        HelloWorld some ->
            "hello_world"

        WelcomePCSetup ->
            "welcome_pc_setup"

        WelcomeBackThanks ->
            "back_thanks"
