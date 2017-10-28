module OS.Toasts.Messages exposing (Msg(..))

import OS.Toasts.Models exposing (Toast, Parent)


type Msg
    = Append Toast
    | Remove Int
    | Trash Int
    | Fade Int
