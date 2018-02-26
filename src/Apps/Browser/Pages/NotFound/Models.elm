module Apps.Browser.Pages.NotFound.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Meta.Types.Network.Site as Site


type alias Model =
    { url : Site.Url
    }


initialModel : Site.Url -> Model
initialModel url =
    { url = url
    }


getTitle : Model -> String
getTitle { url } =
    "Unknown " ++ url
