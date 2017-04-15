module OS.Models exposing (Model, initialModel)

import OS.WindowManager.Models
import OS.Dock.Models


type alias Model =
    { wm : OS.WindowManager.Models.Model
    , dock : OS.Dock.Models.Model
    }


initialModel : Model
initialModel =
    { wm = OS.WindowManager.Models.initialModel
    , dock = OS.Dock.Models.initialModel
    }
