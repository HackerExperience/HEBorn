module Apps.Email.Messages exposing (Msg(..))

import Apps.Email.Menu.Messages as Menu
import Game.Storyline.Emails.Models as Emails exposing (Person)
import Game.Storyline.Emails.Contents exposing (Content)


type Msg
    = MenuMsg Menu.Msg
    | SelectContact String
