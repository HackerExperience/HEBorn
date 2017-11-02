module OS.Toasts.Messages exposing (Msg(..))

import OS.Toasts.Models exposing (Toast)


type Msg
    = Insert Toast
    | Remove Int
    | Trash Int
    | Fade Int
