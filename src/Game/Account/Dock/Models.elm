module Game.Account.Dock.Models exposing (Model, initialModel)

import Apps.Models as Apps


type alias Model =
    List Apps.App


initialModel : Model
initialModel =
    [ Apps.BrowserApp
    , Apps.ExplorerApp
    , Apps.LogViewerApp
    , Apps.TaskManagerApp
    ]
