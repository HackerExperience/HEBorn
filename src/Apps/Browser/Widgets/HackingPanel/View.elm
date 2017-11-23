module Apps.Browser.Widgets.HackingPanel.View
    exposing
        ( Config
        , hackingPanel
        )

import Html exposing (..)
import Html.Events exposing (onClick)
import Apps.Apps as Apps
import Apps.Models as Apps
import Game.Meta.Types.Network exposing (NIP)
import Apps.Browser.Pages.CommonActions exposing (CommonActions(..))


type alias Config msg =
    { onCommonAction : CommonActions -> msg
    , onSetShowingPanel : Bool -> msg
    , apps : List Apps.App
    , allowAnyMap : Bool
    , allowSelectEndpoint : Bool
    }


logout : Config msg -> Html msg
logout { onCommonAction } =
    li
        [ onClick <| onCommonAction Logout ]
        [ text "Logout" ]


goBack : Config msg -> Html msg
goBack { onSetShowingPanel } =
    li
        [ onClick <| onSetShowingPanel False ]
        [ text "Go back" ]


baseOptions : Config msg -> List (Html msg)
baseOptions config =
    [ logout config
    , goBack config
    ]


selectEndpoint : Config msg -> Html msg
selectEndpoint { onCommonAction } =
    li
        [ onClick <| onCommonAction SelectEndpoint ]
        [ text "Open Remote Desktop" ]


anyMap : Config msg -> NIP -> Html msg
anyMap { onCommonAction } nip =
    li
        [ onClick <| onCommonAction <| AnyMap nip ]
        [ text "Start AnyMap" ]


hackingPanel : Config msg -> NIP -> Html msg
hackingPanel config nip =
    let
        options0 =
            [ logout config
            , goBack config
            ]

        options1 =
            if config.allowAnyMap then
                anyMap config nip :: options0
            else
                options0

        options2 =
            if config.allowSelectEndpoint then
                selectEndpoint config :: options1
            else
                options1

        options3 =
            List.foldl (openApp config >> (::)) options2 config.apps
    in
        div [] [ ul [] options3 ]


openApp : Config msg -> Apps.App -> Html msg
openApp { onCommonAction } app =
    li
        [ onClick <| onCommonAction <| OpenApp app ]
        [ text ("Open " ++ Apps.name app) ]
