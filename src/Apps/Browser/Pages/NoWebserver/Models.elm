module Apps.Browser.Pages.NoWebserver.Models exposing (..)

import Game.Network.Types exposing (NIP)
import Game.Web.Types exposing (Url)
import Game.Web.Types as Web
import Apps.Browser.Widgets.HackingToolkit.Model as HackingToolkit


type alias Model =
    { toolkit : HackingToolkit.Model
    , showingPanel : Bool
    }



-- Default page for valid IP without a server


initialModel : Web.Meta -> Model
initialModel meta =
    { toolkit =
        { password = meta.password
        , target = meta.nip
        }
    , showingPanel = True
    }


getTitle : Model -> String
getTitle model =
    "Accessing " ++ (Tuple.second model.toolkit.target)


setShowingPanel : Bool -> Model -> Model
setShowingPanel value model =
    { model | showingPanel = value }


setToolkit : HackingToolkit.Model -> Model -> Model
setToolkit value model =
    { model | toolkit = value }
