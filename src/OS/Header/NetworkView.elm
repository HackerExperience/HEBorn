module OS.Header.NetworkView exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Utils.Html exposing (spacer)
import Game.Data exposing (Data)
import Game.Models as Game
import Game.Meta.Types exposing (Context(..))
import Game.Account.Models as Account
import OS.Header.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
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

        availableNetworks =
            case activeContext of
                Gateway ->
                    []

                Endpoint ->
                    []
    in
        div [ class [ Network ] ]
            [ ul [ class [ AvailableNetworks ] ]
                availableNetworks
            , div [ class [ ActiveNetwork ] ]
                [ div [] [ text account.activeNetwork ]
                , div [] [ text "⌄" ]
                ]
            ]
