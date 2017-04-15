module Apps.Models exposing (AppModel, initialModel)

import Apps.Explorer.Models


type alias AppModel =
    { explorer : Apps.Explorer.Models.Model
    }


initialModel : AppModel
initialModel =
    { explorer = Apps.Explorer.Models.initialModel
    }
