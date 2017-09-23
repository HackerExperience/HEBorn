module Apps.Browser.Pages.Bank.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Network.Types as Network
import Game.Web.Types exposing (Url, BankMetadata)
import Game.Web.Types as Web exposing (Site)


type alias Model =
    { title : String
    , location : ( Float, Float )
    }


initialModel : Url -> BankMetadata -> Model
initialModel url meta =
    { title = meta.title
    , location = ( 0, 0 )
    }


getTitle : Model -> String
getTitle { title } =
    title ++ " Bank"
