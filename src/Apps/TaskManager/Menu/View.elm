module Apps.TaskManager.Menu.View exposing (menuView)

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
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
        MenuGeneric ->
            []
