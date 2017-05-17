module Apps.Messages exposing (AppMsg(..), appBinds)

import Events.Models
import Requests.Models
import Core.Components exposing (Component)
import Apps.Explorer.Messages
import Apps.LogViewer.Messages
import Apps.Browser.Messages


type AppMsg
    = MsgExplorer Apps.Explorer.Messages.Msg
    | MsgLogViewer Apps.LogViewer.Messages.Msg
    | MsgBrowser Apps.Browser.Messages.Msg
    | Event Events.Models.Event
    | Request Requests.Models.Request Component
    | Response Requests.Models.Request Requests.Models.Response
    | NoOp


appBinds =
    { explorer = Apps.Explorer.Messages.Response
    , logViewer = Apps.LogViewer.Messages.Response
    , browser = Apps.Browser.Messages.Response
    }
