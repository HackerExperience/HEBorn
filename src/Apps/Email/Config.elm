module Apps.Email.Config exposing (..)

import Game.Storyline.Models as Storyline
import Apps.Email.Messages exposing (..)
import Apps.Params as AppParams exposing (AppParams)


{-| Callbacks:

  - `onOpenApp` callback always opens in gateway context, change it if
    needed.

-}
type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , story : Storyline.Model
    , onOpenApp : AppParams -> msg
    }
