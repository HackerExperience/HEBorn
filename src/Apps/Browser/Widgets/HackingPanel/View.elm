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
import Game.Servers.Shared as Servers


type alias Config msg =
    { onLogout : NIP -> msg
    , batchMsg : List msg -> msg
    , onSetEndpoint : Maybe Servers.CId -> msg
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


selectEndpoint : Config msg -> NIP -> Html msg
selectEndpoint { batchMsg, onSelectEndpoint, onSetEndpoint } nip =
    li
        [ onClick <|
            batchMsg
                [ onSetEndpoint (Just <| Servers.EndpointCId nip)
                , onSelectEndpoint
                ]
        ]
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
                selectEndpoint config nip :: options1
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
