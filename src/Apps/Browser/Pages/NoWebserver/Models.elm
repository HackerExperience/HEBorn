module Apps.Browser.Pages.NoWebserver.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Network.Types exposing (NIP)
import Game.Web.Types exposing (Url)
import Game.Web.Types as Web exposing (Site)


type alias Model =
    { password : Maybe String
    , target : NIP
    }



-- Default page for valid IP without a server


initialModel : Site -> Model
initialModel site =
    { password = site.password
    , target = site.nip
    }


getTitle : Model -> String
getTitle { target } =
    "Accessing " ++ (Tuple.second target)
