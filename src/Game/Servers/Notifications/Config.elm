module Game.Servers.Notifications.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Game.Servers.Notifications.Shared exposing (..)
import Game.Servers.Notifications.Messages exposing (..)
import Game.Servers.Filesystem.Shared as Filesystem


{-| Config de Server.Notifications, contém uma mensagens configuraveis:

  - onToast

Utilizado para criar uma toast. Passa conteúdo da toast.

-}
type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , lastTick : Time
    , onToast : Content -> msg
    }


{-| Config utilizada nas funções do arquivo OnClick.
-}
type alias ActionConfig msg =
    { batchMsg : List msg -> msg
    , openTaskManager : msg
    , openHackedDatabase : msg
    , openExplorerInFile : Filesystem.FileEntry -> msg
    }
