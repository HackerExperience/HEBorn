module Apps.LogFlix.Menu.View exposing (menuView)

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Game.Servers.Logs.Models as Logs
import Apps.LogFlix.Models exposing (Model)
import Apps.LogFlix.Messages as LogFlix
import Apps.LogFlix.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.LogFlix.Menu.Models exposing (Menu(..))


menuView : Model -> Html LogFlix.Msg
menuView model =
    menuViewCreator
        LogFlix.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute LogFlix.Msg
menuFor context =
    menuForCreator LogFlix.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        Dummy ->
            []
