module Apps.Browser.Pages.Webserver.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Network.Types as Network
import Game.Web.Types exposing (Url, WebserverMetadata)
import Game.Web.Types as Web exposing (Site)


type alias Model =
    { password : Maybe String
    , url : Url
    }



-- Default page for valid IP with a server


initialModel : Site -> WebserverMetadata -> Model
initialModel site meta =
    { password = site.password
    , url = site.url
    }


getTitle : Model -> String
getTitle { url } =
    "Accessing " ++ url
