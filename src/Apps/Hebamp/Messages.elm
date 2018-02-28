module Apps.Hebamp.Messages exposing (Msg(..))

import Apps.Hebamp.Shared exposing (Params)


type Msg
    = TimeUpdate String Float
    | Play
    | Pause
    | SetCurrentTime Float
    | Close
    | LaunchApp Params
