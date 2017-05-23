module Apps.Subscriptions exposing (subscriptions)

import Apps.Models exposing (..)
import Apps.Messages exposing (AppMsg(..))
import Apps.LogViewer.Models as LogViewer
import Apps.LogViewer.Messages as LogViewer
import Apps.LogViewer.Subscriptions as LogViewer


subscriptions game model =
    case model of
        LogViewerModel model ->
            LogViewer.subscriptions game model
                |> Sub.map LogViewerMsg
