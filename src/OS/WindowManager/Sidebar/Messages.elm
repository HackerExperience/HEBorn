module OS.WindowManager.Sidebar.Messages exposing (Msg(..), WidgetMsg(..))

import Game.Meta.Types.Desktop.Widgets as DesktopWidget exposing (DesktopWidget)
import OS.WindowManager.Sidebar.Shared exposing (WidgetID)
import Widgets.Params exposing (..)
import Widgets.QuestHelper.Messages as Quest


type Msg
    = ToggleVisibility
    | NewWidget DesktopWidget (Maybe WidgetParams)
    | Remove WidgetID
    | Prioritize WidgetID
    | Deprioritize WidgetID
    | WidgetMsg WidgetID WidgetMsg


type WidgetMsg
    = ToggleExpanded
    | IncreaseOrder
    | DecreaseOrder
    | QuestHelperMsg Quest.Msg
