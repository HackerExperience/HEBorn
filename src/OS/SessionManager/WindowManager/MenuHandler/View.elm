module OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )

import Html exposing (Html)
import Html.Attributes
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.Models exposing (..)


type alias LiftToItemGroups context msg model =
    model -> context -> List (List ( ContextMenu.Item, msg ))


menuViewCreator :
    (msgA -> msgB)
    -> model
    -> Model context
    -> (ContextMenu.Msg context -> msgA)
    -> LiftToItemGroups context msgA model
    -> Html msgB
menuViewCreator sourceMsg model context msg menu =
    Html.map sourceMsg
        (ContextMenu.view
            context.config
            msg
            (menu model)
            context.menu
        )


menuForCreator :
    (msgA -> msgB)
    -> (ContextMenu.Msg context -> msgA)
    -> context
    -> Html.Attribute msgB
menuForCreator sourceMsg msg context =
    Html.Attributes.map sourceMsg (ContextMenu.open msg context)
