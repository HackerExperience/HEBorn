module OS.Header.AccountView exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Game.Models as Game
import Game.Account.Models as Account
import Game.Storyline.Models as Story
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : OpenMenu -> Game.Model -> Html Msg
view openMenu game =
    if openMenu == AccountOpen then
        visibleAccountGear game
    else
        invisibleAccountGear


visibleAccountGear : Game.Model -> Html Msg
visibleAccountGear { account, story } =
    [ toggleCampaignBtn account story
    , logoutBtn
    ]
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


toggleCampaignBtn : Account.Model -> Story.Model -> Html Msg
toggleCampaignBtn account { enabled } =
    let
        canSwitch =
            not account.inTutorial

        getButtonName =
            if enabled then
                "Go Multiplayer"
            else
                "Go Campaign"
    in
        if canSwitch then
            text getButtonName
                |> List.singleton
                |> button
                    [ enabled
                        |> not
                        |> ToggleCampaign
                        |> onClick
                    ]
                |> List.singleton
                |> li []
        else
            text ""


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
