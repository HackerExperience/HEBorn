module OS.Header.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Resources exposing (..)
import OS.Header.TaskbarView as Taskbar
import OS.Header.ConnectionBarView as ConnBar
import OS.Header.NetworkView as NetworkTongue


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data model =
    div [ class [ Header ] ]
        [ logo
        , ConnBar.view data model
        , Taskbar.view data model
        , NetworkTongue.view data (model.openMenu == NetworkOpen)
        ]



-- internals


logo : Html Msg
logo =
    div
        [ class [ Logo ] ]
        [ text "D'LayDOS" ]
