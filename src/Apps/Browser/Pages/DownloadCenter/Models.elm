module Apps.Browser.Pages.DownloadCenter.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Web.Types as Web
import Apps.Browser.Widgets.HackingToolkit.Model as HackingToolkit


type alias Model =
    { toolkit : HackingToolkit.Model
    }


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
