module OS.Context.View
    exposing
        ( contextView
        , contextEmpty
        )

import Html exposing (Html)
import Html.Attributes
import ContextMenu exposing (ContextMenu)
import Core.Messages exposing (CoreMsg(MsgOS))
import OS.WindowManager.ContextHandler.View
    exposing
        ( contextForCreator
        , contextViewCreator
        )
import OS.Models exposing (Model)
import OS.Messages exposing (OSMsg(ContextMsg))
import OS.Context.Messages exposing (Msg(..), MenuAction(..))
import OS.Context.Models exposing (Context(..))


contextView : Model -> Html CoreMsg
contextView model =
    Html.map MsgOS
        (contextViewCreator
            ContextMsg
            model
            model.context
            MenuMsg
            menu
        )


contextFor : Context -> Html.Attribute CoreMsg
contextFor context =
    Html.Attributes.map MsgOS (contextForCreator ContextMsg MenuMsg context)


menu : Model -> Context -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        ContextEmpty ->
            []


contextEmpty : Html.Attribute CoreMsg
contextEmpty =
    contextFor ContextEmpty
