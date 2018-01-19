module Apps.BackFlix.Menu.View exposing (menuView)

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Game.Servers.Logs.Models as Logs
import Apps.BackFlix.Models exposing (Model)
import Apps.BackFlix.Messages as BackFlix
import Apps.BackFlix.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.BackFlix.Menu.Models exposing (Menu(..))


menuView : Model -> Html BackFlix.Msg
menuView model =
    menuViewCreator
        BackFlix.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute BackFlix.Msg
menuFor context =
    menuForCreator BackFlix.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        Dummy ->
            []
