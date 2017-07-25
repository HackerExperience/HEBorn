module Apps.Browser.Pages.Default.Models
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



-- Default page for valid IP without a server


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
    ( Web.Default, Nothing )
