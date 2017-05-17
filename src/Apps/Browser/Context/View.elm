module Apps.Browser.Context.View
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
import Apps.Instances.Models exposing (InstanceID)
import Apps.Browser.Models exposing (Model)
import Apps.Browser.Messages as BrowserMsg
import Apps.Browser.Context.Messages exposing (Msg(..), MenuAction(..))
import Apps.Browser.Context.Models exposing (Context(..))


contextView : Model -> InstanceID -> Html BrowserMsg.Msg
contextView model id =
    contextViewCreator
        BrowserMsg.ContextMsg
        model
        model.menu
        MenuMsg
        (menu id)


contextFor : Context -> Html.Attribute BrowserMsg.Msg
contextFor context =
    contextForCreator BrowserMsg.ContextMsg MenuMsg context


menu : InstanceID -> Model -> Context -> List (List ( ContextMenu.Item, Msg ))
menu id model context =
    case context of
        ContextNav ->
            [ [ ( ContextMenu.item "A", MenuClick DoA id )
              , ( ContextMenu.item "B", MenuClick DoB id )
              ]
            ]

        ContextContent ->
            [ [ ( ContextMenu.item "c", MenuClick DoB id )
              , ( ContextMenu.item "d", MenuClick DoA id )
              ]
            ]


contextNav : Html.Attribute BrowserMsg.Msg
contextNav =
    contextFor ContextNav


contextContent : Html.Attribute BrowserMsg.Msg
contextContent =
    contextFor ContextContent
