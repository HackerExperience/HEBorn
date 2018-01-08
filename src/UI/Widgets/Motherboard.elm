module UI.Widgets.Motherboard exposing (guessMobo, defaultMobo)

import Html exposing (Html)
import Dict
import Svg exposing (svg, use)
import Svg.Attributes exposing (..)
import Utils.Svg.Events exposing (onClickMe)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)


guessMobo : (Motherboard.SlotId -> msg) -> Motherboard -> Html msg
guessMobo =
    -- TODO: When others mobos appears, add a case here to autoselect them
    defaultMobo


defaultMobo : (Motherboard.SlotId -> msg) -> Motherboard -> Html msg
defaultMobo select { slots } =
    let
        onCPU =
            "cpu_0"
                |> select
                |> onClickMe

        hasCPU =
            hasComponent "cpu_0" slots

        onNIC =
            "nic_0"
                |> select
                |> onClickMe

        hasNIC =
            hasComponent "nic_0" slots

        onHDD =
            "hdd_0"
                |> select
                |> onClickMe

        hasHDD =
            hasComponent "hdd_0" slots
    in
        svg
            [ fill "none"
            , stroke "#000"
            ]
            [ use [ xlinkHref "images/mobo.svg#Motherboard" ] []
            , use [ hasCPU, onCPU, xlinkHref "images/mobo.svg#CPU_1_" ] []
            , use [ hasHDD, onHDD, xlinkHref "images/mobo.svg#Hard_Drive_1_" ] []
            , use [ hasNIC, onNIC, xlinkHref "images/mobo.svg#GPU_1_" ] []
            ]



-- internals


hasComponent : String -> Motherboard.Slots -> Svg.Attribute msg
hasComponent id slots =
    case Dict.get id slots of
        Just { component } ->
            case component of
                Just _ ->
                    style "stroke: black"

                Nothing ->
                    style "stroke: lightGray"

        Nothing ->
            style "stroke: none"
