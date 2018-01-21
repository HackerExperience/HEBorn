module Apps.FloatingHeads.Config exposing (..)

import Game.Storyline.Emails.Models as Emails
import Game.Storyline.Emails.Contents.Config as Content
import Apps.FloatingHeads.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , emails : Emails.Model
    , username : String
    }


contentConfig : Config msg -> Content.Config
contentConfig { username } =
    { username = username }
