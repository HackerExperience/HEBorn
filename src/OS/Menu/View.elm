module OS.Menu.View
    exposing
        ( menuView
        , menuEmpty
        )

import Html exposing (Html)
import Html.Attributes
import ContextMenu exposing (ContextMenu)
import Core.Messages as Core
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import OS.Models as OS
import OS.Messages as OS
import OS.Menu.Messages exposing (Msg(..), MenuAction(..))
import OS.Menu.Models exposing (Menu(..))


menuView : OS.Model -> Html Core.Msg
menuView model =
    Html.map Core.OSMsg
        (menuViewCreator
            OS.MenuMsg
            model
            model.menu
            MenuMsg
            menu
        )


menuFor : Menu -> Html.Attribute Core.Msg
menuFor context =
    Html.Attributes.map Core.OSMsg
        (menuForCreator OS.MenuMsg MenuMsg context)


menu : OS.Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuEmpty ->
            []


menuEmpty : Html.Attribute Core.Msg
menuEmpty =
    menuFor MenuEmpty
