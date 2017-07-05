module Apps.ConnManager.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Entries.FilterHeader exposing (filterHeader)
import Game.Network.Models as Network exposing (Tunnel, Connection, ConnectionType(..))
import Apps.ConnManager.Messages exposing (Msg(..))
import Apps.ConnManager.Models exposing (..)
import Apps.ConnManager.Resources exposing (Classes(..), prefix)
import Apps.ConnManager.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


connView : Connection -> Html Msg
connView conn =
    div []
        [ text " * Conn with type: "
        , text <| connTypeToString conn.type_
        ]


tunnelView : Tunnel -> Html Msg
tunnelView tnl =
    div [ class [ GroupedTunnel ] ]
        [ text "Gateway: "
        , text tnl.gateway
        , br [] []
        , text "Endpoint: "
        , text tnl.endpoint
        , br [] []
        , text "Connections: "
        , tnl.connections
            |> Dict.values
            |> List.map connView
            |> div []
        ]


connTypeToString : ConnectionType -> String
connTypeToString src =
    case src of
        ConnectionFTP ->
            "FTP"

        ConnectionSSH ->
            "SSH"

        ConnectionX11 ->
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

        mainEntries =
            data.game.network.tunnels
                |> Dict.values
                |> List.map tunnelView
                |> verticalList
    in
        verticalSticked
            (Just [ filterHeaderLayout ])
            [ mainEntries
            , menuView model
            ]
            Nothing
