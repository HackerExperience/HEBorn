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
    }


initialModel : Web.Url -> Web.BankContent -> Model
initialModel url content =
    { title = content.title
    }


getTitle : Model -> String
getTitle { title } =
    title ++ " Bank"
