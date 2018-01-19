module Apps.Explorer.Menu.View
    exposing
        ( menuView
        , menuMainDir
        , menuTreeDir
        , menuMainArchive
        , menuTreeArchive
        , menuExecutable
        , menuActiveAction
        , menuPassiveAction
        )

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import Game.Servers.Filesystem.Shared as Filesystem
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Apps.Explorer.Models exposing (Model, EditingStatus(..))
import Apps.Explorer.Messages as ExplorerMsg
import Apps.Explorer.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.Explorer.Menu.Models exposing (Menu(..))


menuView : Model -> Html ExplorerMsg.Msg
menuView model =
    menuViewCreator
        ExplorerMsg.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute ExplorerMsg.Msg
menuFor context =
    menuForCreator ExplorerMsg.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuMainDir path ->
            [ [ ( ContextMenu.item "Enter"
                , MenuClick <| GoPath path
                )
              , ( ContextMenu.item "Rename"
                , MenuClick <| EnterRenameDir path
                )
              , ( ContextMenu.item "Move"
                , MenuClick <| UpdateEditing <| MovingDir path
                )
              , ( ContextMenu.item "Delete"
                , MenuClick <| DeleteDir path
                )
              ]
            ]

        MenuTreeDir path ->
            [ [ ( ContextMenu.item "Toogle expansion"
                , MenuClick Dummy
                )
              , ( ContextMenu.item "Rename"
                , MenuClick <| EnterRenameDir path
                )
              , ( ContextMenu.item "Delete Link"
                , MenuClick Dummy
                )
              ]
            ]

        MenuMainArchive fileID ->
            [ [ ( ContextMenu.item "Rename"
                , MenuClick <| EnterRename fileID
                )
              , ( ContextMenu.item "Move"
                , MenuClick <| UpdateEditing <| Moving fileID
                )
              , ( ContextMenu.item "Delete"
                , MenuClick <| Delete fileID
                )
              ]
            ]

        MenuTreeArchive fileID ->
            [ [ ( ContextMenu.item "Rename"
                , MenuClick <| EnterRename fileID
                )
              , ( ContextMenu.item "Delete"
                , MenuClick <| Delete fileID
                )
              ]
            ]

        MenuExecutable fileID ->
            [ [ ( ContextMenu.item "Run"
                , MenuClick <| Run fileID
                )
              , ( ContextMenu.item "Research"
                , MenuClick <| Research fileID
                )
              , ( ContextMenu.item "Rename"
                , MenuClick <| EnterRename fileID
                )
              , ( ContextMenu.item "Move"
                , MenuClick <| UpdateEditing <| Moving fileID
                )
              , ( ContextMenu.item "Delete"
                , MenuClick <| Delete fileID
                )
              ]
            ]

        MenuActiveAction fileID ->
            [ [ ( ContextMenu.item "Run"
                , MenuClick <| Run fileID
                )
              ]
            ]

        MenuPassiveAction fileID ->
            [ [ ( ContextMenu.item "Start"
                , MenuClick <| Start fileID
                )
              , ( ContextMenu.item "Stop"
                , MenuClick <| Stop fileID
                )
              ]
            ]


menuMainDir : Filesystem.Path -> Html.Attribute ExplorerMsg.Msg
menuMainDir path =
    menuFor (MenuMainDir path)


menuTreeDir : Filesystem.Path -> Html.Attribute ExplorerMsg.Msg
menuTreeDir path =
    menuFor (MenuTreeDir path)


menuMainArchive : Filesystem.Id -> Html.Attribute ExplorerMsg.Msg
menuMainArchive id =
    menuFor (MenuMainArchive id)


menuTreeArchive : Filesystem.Id -> Html.Attribute ExplorerMsg.Msg
menuTreeArchive id =
    menuFor (MenuTreeArchive id)


menuExecutable : Filesystem.Id -> Html.Attribute ExplorerMsg.Msg
menuExecutable id =
    menuFor (MenuExecutable id)


menuPassiveAction : Filesystem.Id -> Html.Attribute ExplorerMsg.Msg
menuPassiveAction id =
    menuFor (MenuPassiveAction id)


menuActiveAction : Filesystem.Id -> Html.Attribute ExplorerMsg.Msg
menuActiveAction id =
    menuFor (MenuActiveAction id)
