module Apps.Models exposing (AppModel, initialModel)

import Apps.Explorer.Models
import Apps.LogViewer.Models


type alias AppModel =
    { explorer : Apps.Explorer.Models.Model
    , logViewer : Apps.LogViewer.Models.Model
    }


initialModel : AppModel
initialModel =
    { explorer = Apps.Explorer.Models.initialModel
    , logViewer = Apps.LogViewer.Models.initialModel
    }
