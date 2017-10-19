module Setup.Types exposing (..)


type alias Pages =
    List Page


type Page
    = Welcome
    | CustomWelcome
    | SetHostname
    | PickLocation
    | ChooseTheme
    | Finish
