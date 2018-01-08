module Apps.Browser.Pages.Home.Config exposing (Config)


type alias Config msg =
    { onNewTabIn : String -> msg
    , onGoAddress : String -> msg
    }
