module Apps.FloatingHeads.Messages exposing (Msg(..))

import Apps.FloatingHeads.Menu.Messages as Menu
import Game.Storyline.Emails.Contents exposing (Content)


type Msg
    = MenuMsg Menu.Msg
    | HandleSelectContact String
    | ToggleMode
    | Reply Content
    | Close
