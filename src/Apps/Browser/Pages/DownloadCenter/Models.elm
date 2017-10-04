module Apps.Browser.Pages.DownloadCenter.Models exposing (..)

import Game.Web.Types as Web
import Apps.Browser.Widgets.HackingToolkit.Model as HackingToolkit


type alias Model =
    { toolkit : HackingToolkit.Model
    , showingPanel : Bool
    , title : String
    }


initialModel : Web.Meta -> Web.DownloadCenterContent -> Model
initialModel meta { title } =
    { toolkit =
        { password = meta.password
        , target = meta.nip
        }
    , showingPanel = True
    , title = title
    }


getTitle : Model -> String
getTitle { toolkit } =
    "Accessing " ++ (Tuple.second toolkit.target)


setShowingPanel : Bool -> Model -> Model
setShowingPanel value model =
    { model | showingPanel = value }


setToolkit : HackingToolkit.Model -> Model -> Model
setToolkit value model =
    { model | toolkit = value }
