module OS.WindowManager.Sidebar.Messages exposing (Msg(..), WidgetMsg(..))

import Game.Meta.Types.Desktop.Widgets as DesktopWidget exposing (DesktopWidget)
import OS.WindowManager.Sidebar.Shared exposing (WidgetId)
import Widgets.Params exposing (..)
import Widgets.TaskList.Messages as Tasks


type Msg
    = ToggleVisibility
    | NewWidget DesktopWidget (Maybe WidgetParams)
    | Remove WidgetId
    | Prioritize WidgetId
    | Deprioritize WidgetId
    | WidgetMsg WidgetId WidgetMsg


type WidgetMsg
    = ToggleExpanded
    | IncreaseOrder
    | DecreaseOrder
    | TaskListMsg Tasks.Msg
