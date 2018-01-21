module Apps.Email.Config exposing (..)

import Game.Storyline.Emails.Models as Emails
import Apps.Email.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , emails : Emails.Model
    , batchMsg : List msg -> msg
    }
