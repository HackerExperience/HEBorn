module Apps.Browser.Pages.NoWebserver.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import Game.Data as Game
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.NoWebserver.Messages exposing (Msg(..))
import Apps.Browser.Pages.NoWebserver.Models exposing (Model)
import Apps.Browser.Widgets.HackingToolkit.View as HackingToolkit exposing (hackingToolkit)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


hackingToolkitConfig : Bool -> HackingToolkit.Config Msg
hackingToolkitConfig showPassword =
    { onInput = UpdatePasswordField
    , onCommonAction = GlobalMsg
    , onEnterPanel = SetShowingPanel True
    , showPassword = showPassword
    }


view : Game.Data -> Model -> Html Msg
view data model =
    let
        endpointMember =
            List.member
                model.toolkit.target
                data.game.account.joinedEndpoints
    in
        if (model.showingPanel && endpointMember) then
            viewPos data model
        else
            viewPre data (not endpointMember) model


viewPre : Game.Data -> Bool -> Model -> Html Msg
viewPre data showPassword model =
    div [ class [ AutoHeight ] ]
        [ div [ class [ DummyTitle ] ]
            [ text "No web server running" ]
        , hackingToolkit data
            (hackingToolkitConfig showPassword)
            model.toolkit
        ]


viewPos : Game.Data -> Model -> Html Msg
viewPos data model =
    ul []
        [ li [] [ text "Open Task Manager" ]
        , li [] [ text "Open Connection Manager" ]
        , li [] [ text "Open Log Viewer" ]
        , li [] [ text "Open File Explorer" ]
        , li [] [ text "Open Remote Desktop" ]
        , li [] [ text "Start AnyMap" ]
        , li [] [ text "Logout" ]
        , li [ onClick <| SetShowingPanel False ] [ text "Go back" ]
        ]
        |> List.singleton
        |> div []
