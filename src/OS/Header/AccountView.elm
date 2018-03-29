module OS.Header.AccountView exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Game.Account.Notifications.Shared as Notifications
import Game.Account.Notifications.OnClick as Notifications
import OS.Header.Config exposing (..)
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Header.Resources exposing (..)
import OS.Header.NotificationsView exposing (notifications)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> OpenMenu -> Html msg
view config openMenu =
    if openMenu == AccountOpen then
        visibleAccountGear config
    else
        Html.map config.toMsg invisibleAccountGear


visibleAccountGear : Config msg -> Html msg
visibleAccountGear ({ toMsg } as config) =
    [ notifications
        config
        Notifications.render
        (Notifications.grabOnClick (accountActionConfig config))
        "Account"
        (toMsg AccountReadAll)
        config.accountNotifications
    , ul [] [ logoutBtn config ]
    ]
        |> div []
        |> List.singleton
        |> indicator
            [ class [ AccountIco ]
            , onMouseEnter <| toMsg MouseEnterDropdown
            , onMouseLeave <| toMsg MouseLeavesDropdown
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


logoutBtn : Config msg -> Html msg
logoutBtn { toMsg } =
    button
        [ onClick <| toMsg SignOut ]
        [ text "Sign out" ]
        |> List.singleton
        |> li []


indicator : List (Attribute a) -> List (Html a) -> Html a
indicator =
    node indicatorNode
