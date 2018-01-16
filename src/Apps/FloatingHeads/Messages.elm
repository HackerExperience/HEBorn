module Apps.FloatingHeads.Messages exposing (Msg(..))

import Game.Storyline.Emails.Contents exposing (Content)
import Game.Storyline.Emails.Contents.Messages as Contents


type Msg
    = ContentMsg Contents.Msg
    | HandleSelectContact String
    | ToggleMode
    | Reply Content
    | Close
