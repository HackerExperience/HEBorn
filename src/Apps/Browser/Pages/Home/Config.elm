module Apps.Browser.Pages.Home.Config exposing (Config)

import Game.Meta.Types.Context exposing (Context)
import Apps.Apps as Apps


type alias Config msg =
    { onNewTabIn : String -> msg
    , onGoAddress : String -> msg
    , onOpenApp : Maybe Context -> Apps.AppParams -> msg
    }
