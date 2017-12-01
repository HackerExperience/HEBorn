module OS.Header.NetworkView exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Utils.Html exposing (spacer)
import Utils.List as List
import Game.Data exposing (Data)
import Game.Models as Game
import Game.Meta.Types.Context exposing (..)
import Game.Meta.Types.Network as Network
import Game.Account.Models as Account
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Data -> Bool -> Html Msg
view data isOpen =
    let
        account =
            data
                |> Game.Data.getGame
                |> Game.getAccount

        activeContext =
            Account.getContext account

        onClickNetwork netId =
            onClick <| SelectNetwork netId

        availableNetworks =
            data
                |> Game.Data.getActiveServer
                |> .nips
                |> List.map
                    (Network.getId)
                |> List.unique
                |> List.filter
                    ((/=) account.activeNetwork)
                |> List.map
                    (\netId ->
                        text netId
                            |> List.singleton
                            |> li [ onClickNetwork netId ]
                    )
    in
        case availableNetworks of
            [] ->
                text ""

            _ ->
                div [ class [ Network ] ]
                    [ div [ class [ ActiveNetwork ] ]
                        [ div [] [ text account.activeNetwork ]
                        , div [] [ text "⌄" ]
                        ]
                    , ul [ class [ AvailableNetworks ] ]
                        availableNetworks
                    ]
