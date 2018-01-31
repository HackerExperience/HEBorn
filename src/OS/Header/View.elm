module OS.Header.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import OS.Header.Config exposing (..)
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Resources exposing (..)
import OS.Header.TaskbarView as Taskbar
import OS.Header.ConnectionBarView as ConnBar
import OS.Header.NetworkView as NetworkTongue


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    div [ class [ Header ], config.menuAttr [] ]
        [ logo
        , ConnBar.view config model
        , Taskbar.view config model
        , NetworkTongue.view config (model.openMenu == NetworkOpen)
        ]



-- internals


logo : Html msg
logo =
    div
        [ class [ Logo ] ]
        [ text "D'LayDOS" ]
