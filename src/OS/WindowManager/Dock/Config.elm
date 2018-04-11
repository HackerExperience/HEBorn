module OS.WindowManager.Dock.Config exposing (..)

import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)
import Game.Account.Dock.Models as Dock
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId)
import Game.Storyline.Models as Story
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
    , servers : Servers.Model
    , story : Story.Model
    }
