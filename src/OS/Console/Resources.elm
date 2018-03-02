module OS.Console.Resources exposing (..)


type Class
    = LogConsole
    | LogConsoleBox
    | LogConsoleHeader
    | LogConsoleDataDiv
    | BFRequest
    | BFReceive
    | BFJoin
    | BFJoinAccount
    | BFJoinServer
    | BFNone
    | BFOther
    | BFEvent
    | BFError


prefix : String
prefix =
    "consl"
