module UI.Elements.Motherboard exposing (guessMobo, defaultMobo)

import Html exposing (Html)
import Svg exposing (Svg, use)
import Svg.Attributes exposing (..)
import Svg.Lazy exposing (lazy3)
import Svg.Keyed exposing (node)
import Utils.Svg.Events exposing (..)
import Game.Meta.Types.Components.Type exposing (Type(..))
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)


guessMobo : (Motherboard.SlotId -> msg) -> Maybe Type -> Motherboard -> Html msg
guessMobo =
    -- TODO: When others mobos appears, add a case here to autoselect them
    lazy3 defaultMobo


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
        node "svg"
            [ fill "red"
            , fillOpacity "0"
            , stroke "black"
            ]
            [ ( "mobo", use [ xlinkHref "images/mobo.svg#Motherboard" ] [] )
            , ( "cpu", lazy3 (genericCompo "CPU_1") onCPU hasCPU highCPU )
            , ( "hdd", lazy3 (genericCompo "HDD_1") onHDD hasHDD highHDD )
            , ( "nic", lazy3 (genericCompo "NIC_1") onNIC hasNIC highNIC )
            , ( "ram", lazy3 (genericCompo "RAM_1") onRAM hasRAM highRAM )
            , ( "nc", lazy3 (genericCompo "NIC_1_NC") onNC hasNC highNC )
            ]



-- internals


genericCompo :
    String
    -> Svg.Attribute msg
    -> Svg.Attribute msg
    -> Svg.Attribute msg
    -> Svg msg
genericCompo id on has high =
    use [ has, on, high, xlinkHref <| "images/mobo.svg#" ++ id ] []


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
                |> onMouseDownWithPrevent

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
                |> onMouseDownWithPrevent

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
