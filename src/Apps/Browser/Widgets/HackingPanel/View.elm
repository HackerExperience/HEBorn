module Apps.Browser.Widgets.HackingPanel.View
    exposing
        ( Config
        , hackingPanel
        )

import Html exposing (..)
import Html.Events exposing (onClick)
import Apps.Shared as Apps
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import Game.Meta.Types.Network exposing (NIP)


type alias Config msg =
    { onLogout : NIP -> msg
    , onSelectEndpoint : msg
    , onAnyMap : NIP -> msg
    , onNewApp : DesktopApp -> msg
    , onSetShowingPanel : Bool -> msg
    , apps : List DesktopApp
    , allowAnyMap : Bool
    , allowSelectEndpoint : Bool
    }


logout : Config msg -> NIP -> Html msg
logout { onLogout } nip =
    li
        [ onClick <| onLogout nip ]
        [ text "Logout" ]


goBack : Config msg -> Html msg
goBack { onSetShowingPanel } =
    li
        [ onClick <| onSetShowingPanel False ]
        [ text "Go back" ]


selectEndpoint : Config msg -> Html msg
selectEndpoint { onSelectEndpoint } =
    li
        [ onClick <| onSelectEndpoint ]
        [ text "Open Remote Desktop" ]


anyMap : Config msg -> NIP -> Html msg
anyMap { onAnyMap } nip =
    li
        [ onClick <| onAnyMap nip ]
        [ text "Start AnyMap" ]


hackingPanel : Config msg -> NIP -> Html msg
hackingPanel config nip =
    let
        options0 =
            [ logout config nip
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


openApp : Config msg -> DesktopApp -> Html msg
openApp { onNewApp } app =
    li
        [ onClick <| onNewApp app ]
        [ text ("Open " ++ Apps.name app) ]
