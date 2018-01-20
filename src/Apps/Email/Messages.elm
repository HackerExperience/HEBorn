module Apps.Email.Messages exposing (Msg(..))

import Game.Storyline.Emails.Models as Emails exposing (Person)
import Game.Storyline.Emails.Contents exposing (Content)


type Msg
    = SelectContact String
