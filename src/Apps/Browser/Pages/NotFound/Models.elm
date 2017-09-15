module Apps.Browser.Pages.NotFound.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Web.Types exposing (Url)


type alias Model =
    { url : Url
    }


initialModel : Url -> Model
initialModel url =
    { url = url
    }


getTitle : Model -> String
getTitle { url } =
    "Unknown " ++ url
