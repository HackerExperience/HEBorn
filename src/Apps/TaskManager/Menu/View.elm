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
import Game.Shared exposing (ID)
import Game.Servers.Processes.Models as Processes
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages as TaskManagerMsg
import Apps.TaskManager.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.TaskManager.Menu.Models exposing (Menu(..))


menuView : Model -> Html TaskManagerMsg.Msg
menuView model =
    menuViewCreator
        TaskManagerMsg.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute TaskManagerMsg.Msg
menuFor context =
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


menuForRunning : Processes.ID -> Html.Attribute TaskManagerMsg.Msg
menuForRunning pID =
    (menuFor (MenuRunningProcess pID))


menuForPaused : Processes.ID -> Html.Attribute TaskManagerMsg.Msg
menuForPaused pID =
    (menuFor (MenuPausedProcess pID))


menuForComplete : Processes.ID -> Html.Attribute TaskManagerMsg.Msg
menuForComplete pID =
    (menuFor (MenuCompleteProcess pID))


menuForPartial : Processes.ID -> Html.Attribute TaskManagerMsg.Msg
menuForPartial pID =
    (menuFor (MenuPartialProcess pID))
