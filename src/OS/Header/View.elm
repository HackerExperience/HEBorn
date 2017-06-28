module OS.Header.View exposing (view)

import Html exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Utils.Html exposing (spacer)
import OS.Style as Css
import OS.Header.Messages exposing (..)
import OS.Header.Models exposing (..)
import Game.Models as Game
import UI.Widgets.CustomSelect exposing (customSelect)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "os"


view : Game.Model -> Model -> Html Msg
view game model =
    div [ class [ Css.Header ] ]
        [ customSelect OpenGatewaySelector SelectGateway 1 [ ( 0, text "::1" ) ]
        , spacer
        , customSelect OpenGatewaySelector SelectGateway 1 [ ( 0, text "::1" ) ]
        , button
            [ onClick Logout
            ]
            [ text "logout" ]
        ]
