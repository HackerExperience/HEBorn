module OS.Menu.View
    exposing
        ( menuView
        , menuEmpty
        )

import Html exposing (Html)
import Html.Attributes
import ContextMenu exposing (ContextMenu)
import Core.Messages exposing (CoreMsg(MsgOS))
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import OS.Models exposing (Model)
import OS.Messages exposing (OSMsg(ContextMenuMsg))
import OS.Menu.Messages exposing (Msg(..), MenuAction(..))
import OS.Menu.Models exposing (Menu(..))


menuView : Model -> Html CoreMsg
menuView model =
    Html.map MsgOS
        (menuViewCreator
            ContextMenuMsg
            model
            model.menu
            MenuMsg
            menu
        )


menuFor : Menu -> Html.Attribute CoreMsg
menuFor context =
    Html.Attributes.map MsgOS (menuForCreator ContextMenuMsg MenuMsg context)


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuEmpty ->
            []


menuEmpty : Html.Attribute CoreMsg
menuEmpty =
    menuFor MenuEmpty
