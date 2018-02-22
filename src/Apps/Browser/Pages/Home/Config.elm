module Apps.Browser.Pages.Home.Config exposing (Config)

import Apps.Params as AppParams exposing (AppParams)


type alias Config msg =
    { onNewTabIn : String -> msg
    , onGoAddress : String -> msg
    , onOpenApp : AppParams -> msg
    }
