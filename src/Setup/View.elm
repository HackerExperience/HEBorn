module Setup.View exposing (view)

import Game.Models as Game
import Native.Untouchable
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Setup.Types exposing (..)
import Setup.Messages exposing (..)
import Setup.Models exposing (..)
import Setup.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Model -> Model -> Html Msg
view game model =
    let
        isActive =
            (==) model.step
    in
        node setupNode
            []
            [ node leftBarNode [] <|
                List.singleton <|
                    ul []
                        [ stepMarker isActive Welcome "WELCOME"
                        , stepMarker isActive PickLocation "LOCATION PICKER"
                        , stepMarker isActive Finish "FINISH"
                        ]
            , viewStep game model
            ]


viewStep : Game.Model -> Model -> Html Msg
viewStep game model =
    case model.step of
        PickLocation ->
            locationPicker model

        Welcome ->
            welcome

        Finish ->
            finish

        _ ->
            div [] []


welcome : Html Msg
welcome =
    node contentNode
        [ class [ StepWelcome ] ]
        [ headerBanner
        , div []
            [ h2 [] [ text "Hello!" ]
            , p []
                [ text "I'm looking for someone to share in an adventure..." ]
            , p []
                [ text "Do you believe in computer fairies? Their job is to protect all your private information. But, be ware, they don't exist!" ]
            , p []
                [ text "So who is protecting you? No one! In the land of bits and pixels there are no gods!" ]
            , p []
                [ text "What are you still doing in this screen? You better be going now, if you really wanna play..." ]
            , div []
                [ button [ onClick <| GoStep PickLocation ] [ text "I'M IN" ] ]
            ]
        ]


locationPicker : Model -> Html Msg
locationPicker model =
    node contentNode
        [ class [ StepPickLocation ] ]
        [ headerBanner
        , div []
            [ h2 [] [ text "Pick your location" ] ]
        , Native.Untouchable.node "hemap" mapId
        , locPickerBox model
        ]


finish : Html Msg
finish =
    node contentNode
        [ class [ StepWelcome ] ]
        [ headerBanner
        , div []
            [ h2 [] [ text "Good bye!" ]
            , p []
                [ text "It was really good, wasn't it?" ]
            , p []
                [ text "Well.. You're ready to leave now." ]
            , p []
                [ text "Maybe you'll find someone else to help you... Maybe Black Mesa!" ]
            , p []
                [ text "What are you waiting fool? Run, Forrest, run!" ]
            , div []
                [ button [ onClick GoOS ] [ text "FINISH HIM" ] ]
            ]
        ]


stepMarker : (a -> Bool) -> a -> String -> Html Msg
stepMarker check key label =
    li
        (if check key then
            [ class [ Selected ] ]
         else
            []
        )
        [ text label ]


headerBanner : Html Msg
headerBanner =
    div []
        [ h1 [] [ text " D'LayDOS" ]
        ]


locPickerBox : Model -> Html Msg
locPickerBox model =
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
                        , text (toString coords.lat)
                        , br [] []
                        , text ">> LON: "
                        , text (toString coords.lng)
                        , br [] []
                        , br [] []
                        , text "PROCESSING AREA INFO..."
                        ]

                    _ ->
                        [ text "PROCESSING LOCATION..."
                        ]

        btns =
            div []
                [ button [ onClick ResetLoc ] [ text "RESET" ]

                -- , span [] []
                , button [ onClick <| GoStep Finish ] [ text "NEXT" ]
                ]
    in
        div [] [ info, btns ]
