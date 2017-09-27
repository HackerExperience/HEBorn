module OS.Toasts.Messages exposing (Msg(..))

import OS.Toasts.Models exposing (Toast, Parent)
import Events.Events as Events


type Msg
    = Append Toast
    | Remove Int
    | Trash Int
    | Fade Int
    | Event Events.Event
