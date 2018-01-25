module Apps.FloatingHeads.Config exposing (..)

import Html exposing (Attribute)
import Apps.Apps as Apps
import Game.Meta.Types.Context exposing (Context)
import Game.Storyline.Emails.Models as Emails
import Game.Storyline.Emails.Contents as Emails
import Game.Storyline.Emails.Contents.Config as Content
import Apps.FloatingHeads.Messages exposing (..)
import Apps.Browser.Models as Browser


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , draggable : Attribute msg
    , emails : Emails.Model
    , username : String
    , onReplyEmail : Emails.Content -> msg
    , onCloseApp : msg
    , onOpenApp : Maybe Context -> Apps.AppParams -> msg
    }


contentConfig : Config msg -> Content.Config msg
contentConfig config =
    { username = config.username
    , onOpenBrowser =
        Browser.OpenAtUrl
            >> Apps.BrowserParams
            >> config.onOpenApp Nothing
    }
