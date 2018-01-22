module OS.Header.NetworkView exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Utils.Html.Attributes exposing (boolAttr)
import Utils.List as List
import Game.Data exposing (Data)
import Game.Meta.Types.Network as Network
import Game.Servers.Models as Servers
import OS.Header.Config exposing (..)
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Bool -> Html Msg
view config isOpen =
    let
        onClickNetwork nip =
            onClick <| SelectNIP nip

        activeNIP =
            config.activeNIP

        availableNetworks =
            config.nips
                |> List.unique
                |> List.filter
                    ((/=) activeNIP)
                |> List.map
                    (\nip ->
                        text (Network.getId nip)
                            |> List.singleton
                            |> li [ onClickNetwork nip ]
                    )
    in
        case availableNetworks of
            [] ->
                text ""

            _ ->
                div [ class [ Network ] ]
                    [ div
                        [ class [ ActiveNetwork ]
                        , onClick <| ToggleMenus NetworkOpen
                        ]
                        [ div [] [ text (Network.getId activeNIP) ]
                        , div [] [ text "⌄" ]
                        ]
                    , ul
                        [ class [ AvailableNetworks ]
                        , boolAttr expandedMenuAttrTag isOpen
                        ]
                        availableNetworks
                    ]
