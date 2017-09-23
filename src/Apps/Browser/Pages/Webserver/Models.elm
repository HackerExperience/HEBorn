module Apps.Browser.Pages.Webserver.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Network.Types as Network
import Game.Web.Types as Web


type alias Model =
    { password : Maybe String
    , url : Web.Url
    }



-- Default page for valid IP with a server


initialModel : Web.Url -> Web.Meta -> Web.WebserverContent -> Model
initialModel url meta content =
    { password = meta.password
    , url = url
    }


getTitle : Model -> String
getTitle { url } =
    "Accessing " ++ url
