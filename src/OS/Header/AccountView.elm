module OS.Header.AccountView exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Game.Models as Game
import Game.Account.Models as Account
import Game.Storyline.Models as Story
import OS.Header.Config exposing (..)
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> OpenMenu -> Html Msg
view config openMenu =
    if openMenu == AccountOpen then
        visibleAccountGear config
    else
        invisibleAccountGear


visibleAccountGear : Config msg -> Html Msg
visibleAccountGear config =
    [ logoutBtn ]
        |> ul []
        |> List.singleton
        |> div
            [ onMouseEnter MouseEnterDropdown
            , onMouseLeave MouseLeavesDropdown
            ]
        |> List.singleton
        |> indicator
            [ class [ Account ] ]


invisibleAccountGear : Html Msg
invisibleAccountGear =
    indicator
        [ class [ Account ]
        , onClick <| ToggleMenus AccountOpen
        ]
        []


logoutBtn : Html Msg
logoutBtn =
    button
        [ onClick Logout ]
        [ text "Logout" ]
        |> List.singleton
        |> li []


indicator : List (Attribute a) -> List (Html a) -> Html a
indicator =
    node indicatorNode
