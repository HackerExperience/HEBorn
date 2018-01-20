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
import Apps.Explorer.Config exposing (..)
import Apps.Explorer.Models exposing (Model, EditingStatus(..))
import Apps.Explorer.Messages as ExplorerMsg
import Apps.Explorer.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.Explorer.Menu.Models exposing (Menu(..))


menuView : Config msg -> Model -> Html msg
menuView config model =
    menuViewCreator
        ExplorerMsg.MenuMsg
        model
        model.menu
        MenuMsg
        (menu config)


menuFor : Menu -> Html.Attribute msg
menuFor context =
    menuForCreator ExplorerMsg.MenuMsg MenuMsg context


menu : Config msg -> Model -> Menu -> List (List ( ContextMenu.Item, msg ))
menu config model context =
    case context of
        MenuMainDir path ->
            [ [ ( ContextMenu.item "Enter"
                , config.toMsg <| MenuClick <| GoPath path
                )
              , ( ContextMenu.item "Rename"
                , config.toMsg <| MenuClick <| EnterRenameDir path
                )
              , ( ContextMenu.item "Move"
                , config.toMsg <| MenuClick <| UpdateEditing <| MovingDir path
                )
              , ( ContextMenu.item "Delete"
                , config.toMsg <| MenuClick <| DeleteDir path
                )
              ]
            ]

        MenuTreeDir path ->
            [ [ ( ContextMenu.item "Toogle expansion"
                , config.toMsg <| MenuClick Dummy
                )
              , ( ContextMenu.item "Rename"
                , config.toMsg <| MenuClick <| EnterRenameDir path
                )
              , ( ContextMenu.item "Delete Link"
                , config.toMsg <| MenuClick Dummy
                )
              ]
            ]

        MenuMainArchive fileID ->
            [ [ ( ContextMenu.item "Rename"
                , config.toMsg <| MenuClick <| EnterRename fileID
                )
              , ( ContextMenu.item "Move"
                , config.toMsg <| MenuClick <| UpdateEditing <| Moving fileID
                )
              , ( ContextMenu.item "Delete"
                , config.toMsg <| MenuClick <| Delete fileID
                )
              ]
            ]

        MenuTreeArchive fileID ->
            [ [ ( ContextMenu.item "Rename"
                , config.toMsg <| MenuClick <| EnterRename fileID
                )
              , ( ContextMenu.item "Delete"
                , config.toMsg <| MenuClick <| Delete fileID
                )
              ]
            ]

        MenuExecutable fileID ->
            [ [ ( ContextMenu.item "Run"
                , config.toMsg <| MenuClick <| Run fileID
                )
              , ( ContextMenu.item "Research"
                , config.toMsg <| MenuClick <| Research fileID
                )
              , ( ContextMenu.item "Rename"
                , config.toMsg <| MenuClick <| EnterRename fileID
                )
              , ( ContextMenu.item "Move"
                , config.toMsg <| MenuClick <| UpdateEditing <| Moving fileID
                )
              , ( ContextMenu.item "Delete"
                , config.toMsg <| MenuClick <| Delete fileID
                )
              ]
            ]

        MenuActiveAction fileID ->
            [ [ ( ContextMenu.item "Run"
                , config.toMsg <| MenuClick <| Run fileID
                )
              ]
            ]

        MenuPassiveAction fileID ->
            [ [ ( ContextMenu.item "Start"
                , config.toMsg <| MenuClick <| Start fileID
                )
              , ( ContextMenu.item "Stop"
                , config.toMsg <| MenuClick <| Stop fileID
                )
              ]
            ]


menuMainDir : Filesystem.Path -> Html.Attribute msg
menuMainDir path =
    menuFor (MenuMainDir path)


menuTreeDir : Filesystem.Path -> Html.Attribute msg
menuTreeDir path =
    menuFor (MenuTreeDir path)


menuMainArchive : Filesystem.Id -> Html.Attribute msg
menuMainArchive id =
    menuFor (MenuMainArchive id)


menuTreeArchive : Filesystem.Id -> Html.Attribute msg
menuTreeArchive id =
    menuFor (MenuTreeArchive id)


menuExecutable : Filesystem.Id -> Html.Attribute msg
menuExecutable id =
    menuFor (MenuExecutable id)


menuPassiveAction : Filesystem.Id -> Html.Attribute msg
menuPassiveAction id =
    menuFor (MenuPassiveAction id)


menuActiveAction : Filesystem.Id -> Html.Attribute msg
menuActiveAction id =
    menuFor (MenuActiveAction id)
