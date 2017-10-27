module Setup.Types exposing (..)


type alias Pages =
    List Page


type Page
    = Welcome
    | CustomWelcome
    | Mainframe
    | PickLocation
    | ChooseTheme
    | Finish
    | CustomFinish
