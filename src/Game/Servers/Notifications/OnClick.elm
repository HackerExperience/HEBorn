module Game.Servers.Notifications.OnClick exposing (..)

{-| Contém funções úteis para views de notificações que tenham eventos de
clique nas notificações.
-}

import Game.Servers.Notifications.Shared exposing (..)
import Game.Servers.Notifications.Config exposing (..)


{-| Mensagem enviada ao clicar na notificação.
-}
grabOnClick : ActionConfig msg -> Content -> msg
grabOnClick config content =
    case content of
        Generic _ _ ->
            -- não fazer nada
            config.batchMsg []

        DownloadStarted _ _ _ ->
            -- abrir gerenciador de tarefas
            config.openTaskManager

        DownloadConcluded _ _ fileEntry ->
            -- abrir explorer na pasta do seguinte arquivo
            config.openExplorerInFile fileEntry

        UploadStarted _ _ _ ->
            -- abrir gerenciador de tarefas
            config.openTaskManager

        UploadConcluded _ _ _ ->
            -- abrir gerenciador de tarefas
            config.openTaskManager

        BruteforceStarted _ ->
            -- abrir gerenciador de tarefas
            config.openTaskManager

        BruteforceConcluded _ ->
            -- abrir hacked database
            config.openHackedDatabase
