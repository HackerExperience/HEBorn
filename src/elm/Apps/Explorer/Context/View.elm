module Apps.Explorer.Context.View
    exposing
        ( contextView
        , contextNav
        , contextContent
        )

import ContextMenu exposing (ContextMenu)
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages exposing (Msg(ContextMenuMsg, Item))
import Apps.Explorer.Context.Models exposing (Context(..))


contextView model =
    ContextMenu.view
        model.context.config
        ContextMenuMsg
        (menu model)
        model.context.menu


menu : Model -> Context -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        ContextNav ->
            [ [ ( ContextMenu.item "A", Item 1 )
              , ( ContextMenu.item "B", Item 2 )
              ]
            ]

        ContextContent ->
            [ [ ( ContextMenu.item "c", Item 3 )
              , ( ContextMenu.item "d", Item 4 )
              ]
            ]


contextNav =
    contextFor ContextNav


contextContent =
    contextFor ContextContent


contextFor context =
    ContextMenu.open ContextMenuMsg context
