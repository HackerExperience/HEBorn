module Apps.Browser.Pages.Webserver.Models exposing (..)

import Game.Meta.Types.Network.Site as Site
import Apps.Browser.Widgets.HackingToolkit.Model as HackingToolkit
import Apps.Browser.Widgets.PublicFiles.Model as PublicFiles


type alias Model =
    { toolkit : HackingToolkit.Model
    , publicFiles : PublicFiles.Model
    , showingPanel : Bool
    , loginFailed : Bool
    , custom : String
    }



-- Default page for valid IP without a server


initialModel : Site.WebserverContent -> Site.Meta -> Model
initialModel { custom } meta =
    { toolkit =
        { password = meta.password
        , target = meta.nip
        }
    , publicFiles = meta.publicFiles
    , showingPanel = True
    , loginFailed = False
    , custom = custom
    }


getTitle : Model -> String
getTitle model =
    "Accessing " ++ (Tuple.second model.toolkit.target)


setShowingPanel : Bool -> Model -> Model
setShowingPanel value model =
    { model | showingPanel = value }


setLoginFailed : Bool -> Model -> Model
setLoginFailed value model =
    { model | loginFailed = value }


setToolkit : HackingToolkit.Model -> Model -> Model
setToolkit value model =
    { model | toolkit = value }
