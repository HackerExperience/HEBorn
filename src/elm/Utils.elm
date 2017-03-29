module Utils exposing (msgToCmd)


import Task


-- I know this is not how it's supposed to be done but until I get a better
-- grasp of Elm, it's good enough.
msgToCmd : a -> Cmd a
msgToCmd msg =
    Task.perform (always msg) (Task.succeed ())


boolToString : Bool -> String
boolToString bool =
    case bool of

        True ->
            "true"

        False ->
            "false"

