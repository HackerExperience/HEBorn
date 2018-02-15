module Apps.FloatingHeads.Config exposing (..)

import Html exposing (Attribute)
import Apps.Params as AppParams exposing (AppParams)
import Game.Meta.Types.Apps.Desktop exposing (Reference)
import Game.Meta.Types.Context exposing (Context)
import Game.Storyline.Emails.Models as Emails
import Game.Storyline.Emails.Contents as Emails
import Game.Storyline.Emails.Contents.Config as Content
import Apps.FloatingHeads.Messages exposing (..)
import Apps.Browser.Models as Browser


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , reference : Reference
    , draggable : Attribute msg
    , emails : Emails.Model
    , username : String
    , onReplyEmail : String -> Emails.Content -> msg
    , onCloseApp : msg
    , onOpenApp : AppParams -> msg
    }


contentConfig : Config msg -> Content.Config msg
contentConfig config =
    { username = config.username
    , onOpenBrowser =
        Browser.OpenAtUrl
            >> AppParams.Browser
            >> config.onOpenApp
    }
