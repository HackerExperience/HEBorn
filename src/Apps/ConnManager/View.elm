module Apps.ConnManager.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Tunnels.Models as Tunnels
import Game.Network.Types exposing (NIP)
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Entries.FilterHeader exposing (filterHeader)
import Apps.ConnManager.Messages exposing (Msg(..))
import Apps.ConnManager.Models exposing (..)
import Apps.ConnManager.Resources exposing (Classes(..), prefix)
import Apps.ConnManager.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


connView : Tunnels.Connection -> Html Msg
connView conn =
    div []
        [ text " * Conn with type: "
        , text <| connTypeToString conn.type_
        ]


tunnelView : NIP -> ( Tunnels.ID, Tunnels.Tunnel ) -> Html Msg
tunnelView gateway ( id, tunnel ) =
    div [ class [ GroupedTunnel ] ]
        [ text "Gateway: "
        , text <| Tuple.second gateway
        , br [] []
        , text "Endpoint: "
        , text <| (id |> Tuple.second |> Tuple.second)
        , br [] []
        , text "Connections: "
        , tunnel
            |> Tunnels.getConnections
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


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    let
        filterHeaderLayout =
            verticalList
                [ filterHeader
                    [ ( class [ IcoUp ], DummyNoOp, False )
                    , ( class [ IcoDown ], DummyNoOp, False )
                    ]
                    []
                    app.filterText
                    "Search..."
                    UpdateTextFilter
                ]

        nip =
            data
                |> Game.getServer
                |> Servers.getNIP

        mainEntries =
            data
                |> Game.getServer
                |> Servers.getTunnels
                |> Dict.toList
                |> List.map (tunnelView nip)
                |> verticalList
    in
        verticalSticked
            (Just [ filterHeaderLayout ])
            [ mainEntries
            , menuView model
            ]
            Nothing
