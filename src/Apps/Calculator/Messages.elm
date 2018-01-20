module Apps.Calculator.Messages exposing (Msg(..))


type Msg
    = Input String
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
