module Apps.Explorer.Context.View
    exposing
        ( contextView
        , contextNav
        , contextContent
        )

import Html exposing (Html)
import Html.Attributes
import ContextMenu exposing (ContextMenu)
import OS.WindowManager.ContextHandler.View
    exposing
        ( contextForCreator
        , contextViewCreator
        )
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages as ExplorerMsg
import Apps.Explorer.Context.Messages exposing (Msg(..), MenuAction(..))
import Apps.Explorer.Context.Models exposing (Context(..))


contextView : Model -> Html ExplorerMsg.Msg
contextView model =
    contextViewCreator
        ExplorerMsg.ContextMsg
        model
        model.context
        MenuMsg
        menu


contextFor : Context -> Html.Attribute ExplorerMsg.Msg
contextFor context =
    contextForCreator ExplorerMsg.ContextMsg MenuMsg context


menu : Model -> Context -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        ContextNav ->
            [ [ ( ContextMenu.item "A", MenuClick DoA )
              , ( ContextMenu.item "B", MenuClick DoB )
              ]
            ]

        ContextContent ->
            [ [ ( ContextMenu.item "c", MenuClick DoB )
              , ( ContextMenu.item "d", MenuClick DoA )
              ]
            ]


contextNav : Html.Attribute ExplorerMsg.Msg
contextNav =
    contextFor ContextNav


contextContent : Html.Attribute ExplorerMsg.Msg
contextContent =
    contextFor ContextContent
