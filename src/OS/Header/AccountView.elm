module OS.Header.AccountView exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Utils.List as List
import Game.Account.Notifications.Shared as Notifications
import OS.Header.Config exposing (..)
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Resources exposing (..)
import OS.Header.NotificationsView exposing (notifications)


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
    [ notifications Notifications.render
        "Account"
        AccountReadAll
        config.accountNotifications
    , ul [] [ logoutBtn ]
    ]
        |> div []
        |> List.singleton
        |> indicator
            [ class [ AccountIco ]
            , onMouseEnter MouseEnterDropdown
            , onMouseLeave MouseLeavesDropdown
            ]


invisibleAccountGear : Html Msg
invisibleAccountGear =
    indicator
        [ class [ AccountIco ]
        , onClick <| ToggleMenus AccountOpen
        , onMouseEnter MouseEnterDropdown
        , onMouseLeave MouseLeavesDropdown
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
