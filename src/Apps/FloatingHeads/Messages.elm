module Apps.FloatingHeads.Messages exposing (Msg(..))

import Apps.FloatingHeads.Models exposing (..)
import Game.Meta.Types.Context exposing (Context)
import Game.Storyline.Emails.Contents exposing (Content)
import Game.Storyline.Emails.Contents.Messages as Contents


type Msg
    = ContentMsg Contents.Msg
    | HandleSelectContact String
    | ToggleMode
    | Reply Content
    | Close
    | LaunchApp Context Params
