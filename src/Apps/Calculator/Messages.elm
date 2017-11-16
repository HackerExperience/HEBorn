module Apps.Calculator.Messages exposing (Msg(..))

import Apps.Calculator.Menu.Messages as Menu


type Msg
    = Input String
    | MenuMsg Menu.Msg
    | Sum
    | Subtract
    | Divide
    | Multiply
    | Percent
    | Comma
    | Sqrt
    | CleanAll
    | Backspace
    | Equal
    | KeyMsg Int
