module OS.Dock.View exposing (view)

import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Html.Attributes exposing (attribute)
import Html.CssHelpers
import Core.Messages exposing (CoreMsg(..))
import Core.Models exposing (CoreModel)
import OS.Messages exposing (OSMsg(..))
import OS.WindowManager.Messages exposing (Msg(..))
import OS.Dock.Style as Css
import OS.Dock.Models
    exposing
        ( Application
        , getApplications
        )


{ id, class, classList } =
    Html.CssHelpers.withNamespace "dock"


view : CoreModel -> Html CoreMsg
view model =
    renderApplications model


renderApplications : CoreModel -> Html CoreMsg
renderApplications model =
    let
        applications =
            getApplications model.os.dock

        html =
            List.foldr (\app acc -> [ renderApplication model app ] ++ acc) [] applications
    in
        div [ id Css.DockContainer ]
            [ div
                [ id Css.DockMain ]
                html
            ]


hasInstanceString : Int -> String
hasInstanceString num =
    if (num > 0) then
        "Y"
    else
        "N"


renderApplication : CoreModel -> Application -> Html CoreMsg
renderApplication model application =
    div
        [ class [ Css.Item ]
        , onClick (MsgOS (MsgWM (OpenWindow application.window)))
        , attribute "data-icon" application.icon
        , attribute "data-hasinst" (hasInstanceString application.instancesNum)
        ]
        []
