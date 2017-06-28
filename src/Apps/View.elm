module Apps.View exposing (view)

import Html exposing (Html)
import Apps.Models exposing (..)
import Apps.Messages exposing (..)
import Apps.LogViewer.View as LogViewer
import Apps.TaskManager.View as TaskManager
import Apps.Browser.View as Browser
import Apps.Explorer.View as Explorer
import Game.Data as Game


view : Game.Data -> AppModel -> Html Msg
view data model =
    case model of
        LogViewerModel model ->
            Html.map LogViewerMsg (LogViewer.view data model)

        TaskManagerModel model ->
            Html.map TaskManagerMsg (TaskManager.view data model)

        BrowserModel model ->
            Html.map BrowserMsg (Browser.view data model)

        ExplorerModel model ->
            Html.map ExplorerMsg (Explorer.view data model)
