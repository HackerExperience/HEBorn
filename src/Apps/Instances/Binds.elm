module Apps.Instances.Binds exposing (open, close, context)

import OS.WindowManager.Windows exposing (GameWindow(..))
import Apps.Messages exposing (AppMsg(..))
import Apps.Explorer.Messages as Explorer
import Apps.LogViewer.Messages as LogViewer
import Apps.Browser.Messages as Browser


open window msg =
    case window of
        ExplorerWindow ->
            MsgExplorer (Explorer.OpenInstance msg)

        LogViewerWindow ->
            MsgLogViewer (LogViewer.OpenInstance msg)

        BrowserWindow ->
            MsgBrowser (Browser.OpenInstance msg)


close window msg =
    case window of
        ExplorerWindow ->
            MsgExplorer (Explorer.CloseInstance msg)

        LogViewerWindow ->
            MsgLogViewer (LogViewer.OpenInstance msg)

        BrowserWindow ->
            MsgBrowser (Browser.OpenInstance msg)


context window msg =
    case window of
        ExplorerWindow ->
            MsgExplorer (Explorer.SwitchContext msg)

        LogViewerWindow ->
            MsgLogViewer (LogViewer.OpenInstance msg)

        BrowserWindow ->
            MsgBrowser (Browser.OpenInstance msg)
