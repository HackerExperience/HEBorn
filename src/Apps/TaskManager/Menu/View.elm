module Apps.TaskManager.Menu.View
    exposing
        ( menuView
        , menuForRunning
        , menuForPaused
        , menuForComplete
        , menuForPartial
        )

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Game.Servers.Processes.Models as Processes
import Apps.TaskManager.Menu.Config exposing (..)
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages as TaskManagerMsg
import Apps.TaskManager.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.TaskManager.Menu.Models exposing (Menu(..))


menuView : Config msg -> Model -> Html TaskManagerMsg.Msg
menuView config model =
    menuViewCreator
        TaskManagerMsg.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Config msg -> Menu -> Html.Attribute TaskManagerMsg.Msg
menuFor { toMsg } context =
    menuForCreator TaskManagerMsg.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuRunningProcess pID ->
            [ [ ( ContextMenu.item "Pause", MenuClick (PauseProcess pID) )
              , ( ContextMenu.item "Remove", MenuClick (RemoveProcess pID) )
              ]
            ]

        MenuPausedProcess pID ->
            [ [ ( ContextMenu.item "Resume", MenuClick (ResumeProcess pID) )
              , ( ContextMenu.item "Remove", MenuClick (RemoveProcess pID) )
              ]
            ]

        MenuCompleteProcess pID ->
            [ [ ( ContextMenu.item "Remove", MenuClick (RemoveProcess pID) )
              ]
            ]

        MenuPartialProcess pID ->
            []


menuForRunning : Config msg -> Processes.ID -> Html.Attribute TaskManagerMsg.Msg
menuForRunning config pID =
    menuFor config (MenuRunningProcess pID)


menuForPaused : Config msg -> Processes.ID -> Html.Attribute TaskManagerMsg.Msg
menuForPaused config pID =
    menuFor config (MenuPausedProcess pID)


menuForComplete : Config msg -> Processes.ID -> Html.Attribute TaskManagerMsg.Msg
menuForComplete config pID =
    menuFor config (MenuCompleteProcess pID)


menuForPartial : Config msg -> Processes.ID -> Html.Attribute TaskManagerMsg.Msg
menuForPartial config pID =
    menuFor config (MenuPartialProcess pID)
