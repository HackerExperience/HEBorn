module Apps.Store.Pages.Store.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Web.Types as Web


type alias Model =
    { title : String
    , products : Dict String String
    }


initialModel : Web.Url -> Web.StoreContent -> Model
initialModel url content =
    { title = content.title
    , products = Dict.empty
    }


getTitle : Model -> String
getTitle { title } =
    title ++ " Store"
