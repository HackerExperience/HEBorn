module OS.Menu.View
    exposing
        ( menuView
        , menuEmpty
        )

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import OS.Models as OS
import OS.Messages as OS
import OS.Menu.Messages exposing (Msg(..), MenuAction(..))
import OS.Menu.Models exposing (Menu(..))


menuView : OS.Model -> Html OS.Msg
menuView model =
    (menuViewCreator
        OS.MenuMsg
        model
        model.menu
        MenuMsg
        menu
    )


menuFor : Menu -> Html.Attribute OS.Msg
menuFor context =
    menuForCreator OS.MenuMsg MenuMsg context


menu : OS.Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuEmpty ->
            []


menuEmpty : Html.Attribute OS.Msg
menuEmpty =
    menuFor MenuEmpty
