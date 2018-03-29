module Game.Servers.Notifications.OnClick exposing (..)

import Game.Servers.Notifications.Shared exposing (..)
import Game.Servers.Notifications.Config exposing (..)


grabOnClick : ActionConfig msg -> Content -> msg
grabOnClick config content =
    case content of
        Generic _ _ ->
            config.batchMsg []

        DownloadStarted _ _ _ ->
            config.openTaskManager

        DownloadConcluded _ _ fileEntry ->
            config.openExplorerInFile fileEntry

        UploadStarted _ _ _ ->
            config.openTaskManager

        UploadConcluded _ _ _ ->
            config.openTaskManager
