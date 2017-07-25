module Apps.Browser.Pages.NotFound.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        , getSite
        )

import Game.Web.Types as Web


type alias Model =
    { title : String
    , site : Web.Site
    }


initialModel : Web.Site -> Model
initialModel site =
    { title = site.url
    , site = site
    }


getTitle : Model -> String
getTitle { title } =
    title


getSite : Model -> ( Web.Type, Maybe Web.Meta )
getSite { site } =
    ( Web.NotFound, Nothing )
