module Apps.View exposing (view)

import Html
import Apps.Models exposing (..)
import Apps.Messages exposing (AppMsg(..))
import Apps.LogViewer.View as LogViewer


view game model =
    case model of
        LogViewerModel model ->
            Html.map LogViewerMsg (LogViewer.view game model)
