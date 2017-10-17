module Apps.Browser.Widgets.HackingPanel.View
    exposing
        ( Config
        , hackingPanel
        )

import Html exposing (..)
import Html.Events exposing (onClick)
import Apps.Apps as Apps
import Apps.Models as Apps
import Game.Network.Types exposing (NIP)
import Apps.Browser.Pages.CommonActions exposing (CommonActions(..))


type alias Config msg =
    { onCommonAction : CommonActions -> msg
    , onSetShowingPanel : Bool -> msg
    , apps : List Apps.App
    , allowAnyMap : Bool
    , allowSelectEndpoint : Bool
    }


hackingPanel : Config msg -> NIP -> Html msg
hackingPanel config nip =
    let
        { onCommonAction, onSetShowingPanel } =
            config

        logout =
            li
                [ onClick <| onCommonAction Logout ]
                [ text "Logout" ]

        goBack =
            li
                [ onClick <| onSetShowingPanel False ]
                [ text "Go back" ]

        options0 =
            [ logout
            , goBack
            ]

        options1 =
            if config.allowAnyMap then
                let
                    anyMap =
                        li
                            [ onClick <| onCommonAction <| AnyMap nip ]
                            [ text "Start AnyMap" ]
                in
                    anyMap :: options0
            else
                options0

        options2 =
            if config.allowSelectEndpoint then
                let
                    selectEndpoint =
                        li
                            [ onClick <| onCommonAction SelectEndpoint ]
                            [ text "Open Remote Desktop" ]
                in
                    selectEndpoint :: options1
            else
                options1

        options3 =
            List.foldl (openApp onCommonAction >> (::)) options2 config.apps
    in
        div [] [ ul [] options3 ]


openApp : (CommonActions -> msg) -> Apps.App -> Html msg
openApp onCommonAction app =
    li
        [ onClick <| onCommonAction <| OpenApp app ]
        [ text ("Open " ++ Apps.name app) ]
