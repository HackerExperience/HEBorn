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
import Apps.TaskManager.Config exposing (..)
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages as TaskManagerMsg
import Apps.TaskManager.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.TaskManager.Menu.Models exposing (Menu(..))


menuView : Config msg -> Model -> Html msg
menuView config model =
    menuViewCreator
        TaskManagerMsg.MenuMsg
        model
        model.menu
        MenuMsg
        (menu config)


menuFor : Menu -> Html.Attribute msg
menuFor context =
    menuForCreator TaskManagerMsg.MenuMsg MenuMsg context


menu : Config msg -> Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu config model context =
    case context of
        MenuRunningProcess pID ->
            [ [ ( ContextMenu.item "Pause", config.toMsg <| MenuClick (PauseProcess pID) )
              , ( ContextMenu.item "Remove", config.toMsg <| MenuClick (RemoveProcess pID) )
              ]
            ]

        MenuPausedProcess pID ->
            [ [ ( ContextMenu.item "Resume", config.toMsg <| MenuClick (ResumeProcess pID) )
              , ( ContextMenu.item "Remove", config.toMsg <| MenuClick (RemoveProcess pID) )
              ]
            ]

        MenuCompleteProcess pID ->
            [ [ ( ContextMenu.item "Remove", config.toMsg <| MenuClick (RemoveProcess pID) )
              ]
            ]

        MenuPartialProcess pID ->
            []


menuForRunning : Processes.ID -> Html.Attribute msg
menuForRunning pID =
    (menuFor (MenuRunningProcess pID))


menuForPaused : Processes.ID -> Html.Attribute msg
menuForPaused pID =
    (menuFor (MenuPausedProcess pID))


menuForComplete : Processes.ID -> Html.Attribute msg
menuForComplete pID =
    (menuFor (MenuCompleteProcess pID))


menuForPartial : Processes.ID -> Html.Attribute msg
menuForPartial pID =
    (menuFor (MenuPartialProcess pID))
