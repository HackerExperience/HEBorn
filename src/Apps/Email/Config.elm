module Apps.Email.Config exposing (..)

import Game.Storyline.Models as Storyline
import Game.Meta.Types.Context exposing (Context)
import Apps.Email.Messages exposing (..)
import Apps.Params as AppParams exposing (AppParams)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , story : Storyline.Model
    , onOpenApp : AppParams -> msg
    }
