module Apps.FloatingHeads.Config exposing (..)

import Html exposing (Attribute)
import Apps.Params as AppParams exposing (AppParams)
import Game.Meta.Types.Apps.Desktop exposing (Reference)
import Game.Storyline.Models as Storyline
import Game.Storyline.Shared exposing (ContactId, Reply)
import Game.Storyline.Emails.Config as Emails
import Apps.FloatingHeads.Messages exposing (..)
import Apps.Browser.Models as Browser


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , reference : Reference
    , draggable : Attribute msg
    , story : Storyline.Model
    , username : String
    , onReply : ContactId -> Reply -> msg
    , onCloseApp : msg
    , onOpenApp : AppParams -> msg
    }


contentConfig : Config msg -> Emails.Config msg
contentConfig config =
    { username = config.username
    , onOpenBrowser =
        Browser.OpenAtUrl
            >> AppParams.Browser
            >> config.onOpenApp
    }
