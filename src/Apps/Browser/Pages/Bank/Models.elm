module Apps.Browser.Pages.Bank.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Network.Types as Network
import Game.Web.Types as Web


type alias Model =
    { title : String
    , password : Maybe String
    }


initialModel : Web.Url -> Web.BankContent -> Model
initialModel url content =
    { title = content.title
    , password = Nothing
    }


getTitle : Model -> String
getTitle { title } =
    title ++ " Bank"
