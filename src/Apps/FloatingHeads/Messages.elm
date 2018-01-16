module Apps.FloatingHeads.Messages exposing (Msg(..))

import Game.Storyline.Emails.Contents exposing (Content)


type Msg
    = HandleSelectContact String
    | ToggleMode
    | Reply Content
    | Close
