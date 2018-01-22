module Apps.Email.Config exposing (..)

import Game.Storyline.Emails.Models as Emails
import Game.Meta.Types.Context exposing (Context)
import Apps.Email.Messages exposing (..)
import Apps.Apps as Apps


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , emails : Emails.Model
    , onOpenApp : (Maybe Context) -> Apps.AppParams -> msg
    }
