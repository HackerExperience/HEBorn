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
    , password : Maybe String
    }


initialModel : Site -> BankMetadata -> Model
initialModel site meta =
    { title = meta.title
    , location = ( 0, 0 )
    , password = site.password
    }


getTitle : Model -> String
getTitle { title } =
    title ++ " Bank"
