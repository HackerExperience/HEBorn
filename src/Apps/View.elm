module Apps.View exposing (view)

import Html exposing (Html)
import Apps.Models exposing (..)
import Apps.Messages exposing (..)
import Apps.LogViewer.View as LogViewer
import Apps.TaskManager.View as TaskManager
import Apps.Browser.View as Browser
import Apps.Explorer.View as Explorer
import Game.Models as Game


view : Game.Model -> AppModel -> Html Msg
view game model =
    case model of
        LogViewerModel model ->
            Html.map LogViewerMsg (LogViewer.view game model)

        TaskManagerModel model ->
            Html.map TaskManagerMsg (TaskManager.view game model)

        BrowserModel model ->
            Html.map BrowserMsg (Browser.view game model)

        ExplorerModel model ->
            Html.map ExplorerMsg (Explorer.view game model)
