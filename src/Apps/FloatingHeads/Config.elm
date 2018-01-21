module Apps.FloatingHeads.Config exposing (..)

import Game.Storyline.Emails.Models as Emails
import Game.Storyline.Emails.Contents.Config as Content
import Apps.FloatingHeads.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , emails : Emails.Model
    , username : String
    , batchMsg : List msg -> msg
    }


contentConfig : Config msg -> Content.Config msg
contentConfig config =
    { username = config.username
    , batchMsg = config.batchMsg
    }
