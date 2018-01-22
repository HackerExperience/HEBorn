module Apps.LocationPicker.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Native.Untouchable
import Apps.LocationPicker.Config exposing (..)
import Apps.LocationPicker.Messages exposing (Msg(..))
import Apps.LocationPicker.Models exposing (..)
import Apps.LocationPicker.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    Html.map config.toMsg <|
        div
            [ class [ Super ]
            ]
            [ div [ class [ Map ] ]
                [ Native.Untouchable.node "hemap" model.mapEId ]
            , div [ class [ Interactive ] ] <|
                case model.coordinates of
                    Just coord ->
                        [ text "COORDENADAS"
                        , br [] []
                        , text " LAT: "
                        , text <| toString coord.lat
                        , br [] []
                        , text " LNG: "
                        , text <| toString coord.lng
                        , br [] []
                        , br [] []
                        , text "CLIQUE NO MAPA PARA MUDAR SUA LOCALIZAÇÃO!"
                        ]

                    Nothing ->
                        [ text "CLIQUE ONDE VOCÊ ESTÁ!" ]
            ]
