module Apps.Hebamp.Messages exposing (Msg(..))

import Game.Meta.Types.Context exposing (Context)
import Apps.Hebamp.Shared exposing (Params)


type Msg
    = TimeUpdate String Float
    | Play
    | Pause
    | SetCurrentTime Float
    | Close
    | LaunchApp Context Params
