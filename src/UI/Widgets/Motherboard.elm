module UI.Widgets.Motherboard exposing (guessMobo, defaultMobo)

import Html exposing (Html)
import Dict
import Svg exposing (svg, use)
import Svg.Attributes exposing (..)
import Utils.Svg.Events exposing (onClickMe)
import Game.Meta.Types.Components.Type exposing (Type(..))
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)


guessMobo : (Motherboard.SlotId -> msg) -> Maybe Type -> Motherboard -> Html msg
guessMobo =
    -- TODO: When others mobos appears, add a case here to autoselect them
    defaultMobo


defaultMobo : (Motherboard.SlotId -> msg) -> Maybe Type -> Motherboard -> Html msg
defaultMobo select highlight mobo =
    let
        ( onCPU, hasCPU, highCPU ) =
            getCompo "cpu_1" CPU select highlight mobo

        ( onNIC, hasNIC, highNIC ) =
            getCompo "nic_1" NIC select highlight mobo

        ( onHDD, hasHDD, highHDD ) =
            getCompo "hdd_1" HDD select highlight mobo

        ( onRAM, hasRAM, highRAM ) =
            getCompo "ram_1" RAM select highlight mobo

        ( onNC, hasNC, highNC ) =
            getNC "nic_1" NIC select highlight mobo
    in
        svg
            [ fill "red"
            , fillOpacity "0"
            , stroke "black"
            ]
            [ use [ xlinkHref "images/mobo.svg#Motherboard" ] []
            , use [ hasCPU, onCPU, highCPU, xlinkHref "images/mobo.svg#CPU_1" ] []
            , use [ hasHDD, onHDD, highHDD, xlinkHref "images/mobo.svg#HDD_1" ] []
            , use [ hasNIC, onNIC, highNIC, xlinkHref "images/mobo.svg#NIC_1" ] []
            , use [ hasRAM, onRAM, highRAM, xlinkHref "images/mobo.svg#RAM_1" ] []
            , use [ hasNC, onNC, highNC, xlinkHref "images/mobo.svg#NIC_1_NC" ] []
            ]



-- internals


getCompo :
    Motherboard.SlotId
    -> Type
    -> (Motherboard.SlotId -> msg)
    -> Maybe Type
    -> Motherboard
    -> ( Svg.Attribute msg, Svg.Attribute msg, Svg.Attribute msg )
getCompo slotId type_ select highlight mobo =
    let
        onCompo =
            slotId
                |> select
                |> onClickMe

        hasCompo =
            mobo
                |> Motherboard.getSlot slotId
                |> Maybe.map Motherboard.slotIsEmpty
                |> Maybe.withDefault True
                |> not
                |> hasComponent

        highCompo =
            hightlightIf highlight type_
    in
        ( onCompo, hasCompo, highCompo )


getNC :
    Motherboard.SlotId
    -> Type
    -> (Motherboard.SlotId -> msg)
    -> Maybe Type
    -> Motherboard
    -> ( Svg.Attribute msg, Svg.Attribute msg, Svg.Attribute msg )
getNC slotId type_ select highlight mobo =
    let
        onCompo =
            slotId
                |> select
                |> onClickMe

        hasCompo =
            mobo
                |> Motherboard.slotHasNC slotId
                |> hasComponent

        highCompo =
            hightlightIf highlight type_
    in
        ( onCompo, hasCompo, highCompo )


hasComponent : Bool -> Svg.Attribute msg
hasComponent has =
    if has then
        stroke "black"
    else
        stroke "lightGray"


hightlightIf : Maybe Type -> Type -> Svg.Attribute msg
hightlightIf highlight comp =
    if highlight == (Just comp) then
        fillOpacity "1"
    else
        fillOpacity "0"
