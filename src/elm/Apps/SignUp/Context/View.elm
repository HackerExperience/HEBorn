module Apps.SignUp.Context.View
    exposing
        ( contextView
        , contextOnly
        )

import ContextMenu exposing (ContextMenu)
import Apps.SignUp.Models exposing (Model)
import Apps.SignUp.Messages exposing (Msg(ContextMenuMsgS, ItemS))
import Apps.SignUp.Context.Models exposing (Context(..))


contextView model =
    ContextMenu.view
        model.context.config
        ContextMenuMsgS
        (menu model)
        model.context.menu


menu : Model -> Context -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        ContextOnly ->
            [ [ ( ContextMenu.item "A", ItemS 1 )
              , ( ContextMenu.item "B", ItemS 2 )
              ]
            ]


contextOnly =
    contextFor ContextOnly


contextFor context =
    ContextMenu.open ContextMenuMsgS context
