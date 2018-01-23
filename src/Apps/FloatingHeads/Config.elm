module Apps.FloatingHeads.Config exposing (..)

import Game.Storyline.Emails.Models as Emails
import Game.Storyline.Emails.Contents as Emails
import Game.Storyline.Emails.Contents.Config as Content
import Apps.FloatingHeads.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , emails : Emails.Model
    , username : String
    , onReplyEmail : Emails.Content -> msg
    , onCloseApp : msg
    }


contentConfig : Config msg -> Content.Config msg
contentConfig config =
    { username = config.username
    , batchMsg = config.batchMsg
    }
