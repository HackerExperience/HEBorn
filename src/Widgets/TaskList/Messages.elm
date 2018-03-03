module Widgets.TaskList.Messages exposing (..)


type Msg
    = ToogleCheck Int
    | Update Int String
    | Insert String
    | Remove Int
