module Apps.FloatingHeads.Messages exposing (Msg(..))

import Apps.FloatingHeads.Models exposing (..)
import Game.Meta.Types.Context exposing (Context)
import Game.Storyline.Shared as Story


type Msg
    = HandleSelectContact String
    | ToggleMode
    | Reply Story.Reply
    | Close
    | LaunchApp Params
