module Apps.Hebamp.Messages exposing (Msg(..))


type Msg
    = TimeUpdate String Float
    | Play
    | Pause
    | SetCurrentTime Float
