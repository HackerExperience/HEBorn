module OS.WindowManager.Dock.Config exposing (..)

import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import Game.Account.Dock.Models as Dock
import Game.Servers.Shared exposing (CId)
import OS.WindowManager.Shared exposing (WindowId)


type alias Config msg =
    { onNewApp : DesktopApp -> msg
    , onClickIcon : DesktopApp -> msg
    , onMinimizeAll : DesktopApp -> msg
    , onCloseAll : DesktopApp -> msg
    , onMinimizeWindow : WindowId -> msg
    , onRestoreWindow : WindowId -> msg
    , onCloseWindow : WindowId -> msg
    , accountDock : Dock.Model
    , endpointCId : Maybe CId
    }
