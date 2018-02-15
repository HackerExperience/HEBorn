module Apps.Browser.Pages.Home.Config exposing (Config)

import Game.Meta.Types.Context exposing (Context)
import Apps.Params as AppParams exposing (AppParams)


type alias Config msg =
    { onNewTabIn : String -> msg
    , onGoAddress : String -> msg
    , onOpenApp : AppParams -> msg
    }
