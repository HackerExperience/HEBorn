module Setup.Pages.PickLocation.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (disabled)
import Html.CssHelpers
import Native.Untouchable
import Game.Models as Game
import Setup.Resources exposing (..)
import Setup.Settings as Settings exposing (Settings)
import Setup.Pages.Helpers exposing (withHeader)
import Setup.Pages.PickLocation.Models exposing (..)
import Setup.Pages.PickLocation.Messages exposing (..)
import Setup.Pages.PickLocation.Config exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    withHeader [ class [ StepPickLocation ] ]
        [ div [] [ h2 [] [ text "Pick your location" ] ]
        , Native.Untouchable.node "hemap" mapId
        , locPickerBox config model
        ]


locPickerBox : Config msg -> Model -> Html msg
locPickerBox { toMsg, onNext, onPrevious } model =
    let
        info =
            div [] <|
                case ( model.areaLabel, model.coordinates ) of
                    ( Just areaLabel, _ ) ->
                        [ text "YOU SELECTED: "
                        , text areaLabel
                        ]

                    ( _, Just coords ) ->
                        [ text "SELECTED COORDS: "
                        , br [] []
                        , text ">> LAT: "
                        , text <| toString coords.lat
                        , br [] []
                        , text ">> LON: "
                        , text <| toString coords.lng
                        , br [] []
                        , br [] []
                        , text "PROCESSING AREA INFO..."
                        ]

                    _ ->
                        [ text "PROCESSING LOCATION..."
                        ]

        btns =
            div []
                [ button [ onClick <| toMsg ResetLoc ] [ text "RESET" ]
                , button [ onClick onPrevious ] [ text "BACK" ]
                , buttonNext onNext model
                ]
    in
        div [] [ info, btns ]


buttonNext : (List Settings -> msg) -> Model -> Html msg
buttonNext onNext model =
    let
        attrs =
            if isOkay model then
                [ onClick <| onNext <| settings model ]
            else
                [ disabled True ]
    in
        button attrs [ text "NEXT" ]
