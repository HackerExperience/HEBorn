module OS.Config exposing (..)

import Game.Storyline.Models as Story
import OS.SessionManager.Config as SessionManager
import OS.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , story : Story.Model
    }


smConfig : Config msg -> SessionManager.Config msg
smConfig config =
    { toMsg = SessionManagerMsg >> config.toMsg }
