module Apps.ConnManager.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Game.Servers.Models as Servers
import Game.Servers.Tunnels.Models as Tunnels
import Game.Meta.Types.Network exposing (NIP)
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Entries.FilterHeader exposing (filterHeader)
import Apps.ConnManager.Config exposing (..)
import Apps.ConnManager.Messages exposing (Msg(..))
import Apps.ConnManager.Models exposing (..)
import Apps.ConnManager.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    let
        filterHeaderLayout =
            verticalList
                [ filterHeader
                    [ ( class [ IcoUp ], FilterUp, False )
                    , ( class [ IcoDown ], FilterDown, False )
                    ]
                    []
                    model.filterText
                    "Search..."
                    UpdateTextFilter
                ]

        nip =
            config.activeServer
                |> Servers.getActiveNIP

        mainEntries =
            config.activeServer
                |> .tunnels
                |> Dict.toList
                |> List.map (tunnelView nip)
                |> verticalList
    in
        Html.map config.toMsg <|
            verticalSticked
                (Just [ filterHeaderLayout ])
                [ mainEntries ]
                Nothing


connView : Tunnels.Connection -> Html Msg
connView conn =
    div []
        [ text " * Conn with type: "
        , text <| connTypeToString conn.type_
        ]


tunnelView : NIP -> ( Tunnels.ID, Tunnels.Tunnel ) -> Html Msg
tunnelView gateway ( ( _, _, ip ), tunnel ) =
    div [ class [ GroupedTunnel ] ]
        [ text "Gateway: "
        , text <| Tuple.second gateway
        , br [] []
        , text "Endpoint: "
        , text <| ip
        , br [] []
        , text "Connections: "
        , tunnel
            |> .connections
            |> Dict.values
            |> List.map connView
            |> div []
        ]


connTypeToString : Tunnels.ConnectionType -> String
connTypeToString src =
    case src of
        Tunnels.ConnectionFTP ->
            "FTP"

        Tunnels.ConnectionSSH ->
            "SSH"

        Tunnels.ConnectionX11 ->
            "X11"

        _ ->
            "*UNKNOWN*"
