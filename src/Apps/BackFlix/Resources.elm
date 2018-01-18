module Apps.BackFlix.Resources exposing (..)


type Classes
    = LogBox
    | LogHeader
    | DataDiv
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
    "logfl"
