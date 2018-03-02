module Widgets.Params exposing (..)

import Game.Meta.Types.Desktop.Widgets as DesktopWidget exposing (DesktopWidget)
import Widgets.QuestHelper.Models as QuestHelper


type WidgetParams
    = QuestHelper QuestHelper.Params


toAppType : WidgetParams -> DesktopWidget
toAppType params =
    case params of
        QuestHelper _ ->
            DesktopWidget.QuestHelper


castQuestHelper : WidgetParams -> Maybe QuestHelper.Params
castQuestHelper params =
    case params of
        QuestHelper params ->
            Just params
