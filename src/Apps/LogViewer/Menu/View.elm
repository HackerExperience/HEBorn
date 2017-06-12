module Apps.LogViewer.Menu.View
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
import Game.Servers.Logs.Models exposing (LogID)
import Apps.LogViewer.Models exposing (Model)
import Apps.LogViewer.Messages as LogVwMsg
import Apps.LogViewer.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.LogViewer.Menu.Models exposing (Menu(..))


menuView : Model -> Html LogVwMsg.Msg
menuView model =
    menuViewCreator
        LogVwMsg.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute LogVwMsg.Msg
menuFor context =
    menuForCreator LogVwMsg.MenuMsg MenuMsg context


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


menuNormalEntry : LogID -> Html.Attribute LogVwMsg.Msg
menuNormalEntry logID =
    menuFor (MenuNormalEntry logID)


menuEditingEntry : LogID -> Html.Attribute LogVwMsg.Msg
menuEditingEntry logID =
    menuFor (MenuEditingEntry logID)


menuFilter : Html.Attribute LogVwMsg.Msg
menuFilter =
    menuFor MenuFilter
