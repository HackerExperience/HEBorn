module Setup.Types exposing (..)


type alias Steps =
    List Step


type Step
    = Welcome
    | PickLocation
    | ChooseTheme
    | Finish


stepToString : Step -> String
stepToString step =
    case step of
        Welcome ->
            "Welcome"

        PickLocation ->
            "Location Picker"

        ChooseTheme ->
            "Choose a Theme"

        Finish ->
            "Finish"
