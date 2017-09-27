module Apps.Browser.Pages.NoWebserver.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Network.Types exposing (NIP)
import Game.Web.Types exposing (Url)
import Game.Web.Types as Web
import Apps.Browser.Widgets.HackingToolkit.Model as HackingToolkit


type alias Model =
    { toolkit : HackingToolkit.Model
    }



-- Default page for valid IP without a server


initialModel : Web.Meta -> Model
initialModel meta =
    { toolkit =
        { password = meta.password
        , target = meta.nip
        }
    }


getTitle : Model -> String
getTitle model =
    "Accessing " ++ (Tuple.second model.toolkit.target)
