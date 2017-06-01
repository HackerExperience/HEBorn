module Apps.Messages exposing (AppMsg(..))

import Apps.LogViewer.Messages as LogViewer


type AppMsg
    = LogViewerMsg LogViewer.Msg
