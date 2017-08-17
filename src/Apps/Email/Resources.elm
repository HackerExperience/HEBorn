module Apps.Email.Resources exposing (..)


type Classes
    = Super
    | Active
    | Contacts
    | MainChat
    | From
    | To
    | Sys


prefix : String
prefix =
    "email"
