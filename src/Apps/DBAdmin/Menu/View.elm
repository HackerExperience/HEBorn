module Apps.DBAdmin.Menu.View
    exposing
        ( menuView
        , menuNormalEntry
        , menuEditingEntry
        , menuFilter
        )

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Game.Servers.Logs.Models as Logs
import Apps.DBAdmin.Models exposing (Model)
import Apps.DBAdmin.Messages as DBAdmin
import Apps.DBAdmin.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.DBAdmin.Menu.Models exposing (Menu(..))


menuView : Model -> Html DBAdmin.Msg
menuView model =
    menuViewCreator
        DBAdmin.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute DBAdmin.Msg
menuFor context =
    menuForCreator DBAdmin.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuNormalEntry logID ->
            [ [ ( ContextMenu.item "Edit", MenuClick (NormalEntryEdit logID) )
              ]
            ]

        MenuEditingEntry logID ->
            [ [ ( ContextMenu.item "Apply", MenuClick (EdittingEntryApply logID) )
              , ( ContextMenu.item "Cancel", MenuClick (EdittingEntryCancel logID) )
              ]
            ]

        MenuFilter ->
            -- TODO: Filter by flags
            []


menuNormalEntry : Logs.ID -> Html.Attribute DBAdmin.Msg
menuNormalEntry logID =
    menuFor (MenuNormalEntry logID)


menuEditingEntry : Logs.ID -> Html.Attribute DBAdmin.Msg
menuEditingEntry logID =
    menuFor (MenuEditingEntry logID)


menuFilter : Html.Attribute DBAdmin.Msg
menuFilter =
    menuFor MenuFilter
