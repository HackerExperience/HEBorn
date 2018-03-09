module Css.Utils exposing (..)

import Html
import Html.Attributes as Attributes exposing (style)
import Css exposing (..)


pseudoContent : String -> Style
pseudoContent v =
    property "content" v


type Easing
    = Ease
    | Linear
    | EaseIn
    | EaseOut
    | EaseInOut
    | CubicBezier Int Int Int Int


type IterationCount
    = Number Float
    | Infinite


type Condition
    = EQ String String
    | BOOL String
    | NOT Condition


animation : String -> Float -> Easing -> IterationCount -> Style
animation type_ time easing iteration =
    property "animation"
        (type_
            |> toString
            |> flip (++) " "
            |> flip (++) (toString time)
            |> flip (++) "s "
            |> flip (++) (easingToString easing)
            |> flip (++) " "
            |> flip (++) (iterationCountToString iteration)
        )


iterationCountToString : IterationCount -> String
iterationCountToString iterationCount =
    case interationCount of
        Number num ->
            toString num

        Infinite ->
            "infinite"


easingToString : Easing -> String
easingToString bool =
    case bool of
        Ease ->
            "ease"

        Linear ->
            "linear"

        EaseIn ->
            "ease-in"

        EaseOut ->
            "ease-out"

        EaseInOut ->
            "ease-in-out"

        CubicBezier a b c d ->
            "cubic-bezier(" ++ (toString a) ++ "," ++ (toString b) ++ "," ++ (toString c) ++ "," ++ (toString d) ++ ")"


transition : Float -> String -> Easing -> Style
transition time propertyName easing =
    property "transition" ((toString time) ++ "s " ++ (propertyName) ++ " " ++ (easingToString easing))


conditionToString : Condition -> String
conditionToString cond =
    case cond of
        EQ a b ->
            "[" ++ a ++ "=\"" ++ b ++ "\"" ++ "]"

        BOOL key ->
            "[" ++ key ++ "=\"Y\"]"

        NOT cond ->
            "not(" ++ conditionToString cond ++ ")"


withAttribute : Condition -> List Style -> Style
withAttribute cond =
    pseudoClass <|
        case cond of
            NOT _ ->
                (conditionToString cond)

            _ ->
                "not(iMpOsSiBlE)" ++ (conditionToString cond)


selectableText : Style
selectableText =
    batch
        [ property "-moz-user-select" "text"
        , property "-webkit-user-select" "text"
        , property "-ms-user-select" "text"
        , property "user-select" "text"
        ]


unselectable : Style
unselectable =
    batch
        [ property "-moz-user-select" "none"
        , property "-webkit-user-select" "none"
        , property "-ms-user-select" "none"
        , property "user-select" "none"
        ]


nest : List (List Style -> Style) -> List Style -> Style
nest ns i =
    List.foldr
        (\n a -> n <| List.singleton a)
        (batch i)
        ns


child : (List Style -> Snippet) -> List Style -> Style
child selector styles =
    children <| List.singleton (selector styles)


styles : List Css.Style -> Html.Attribute msg
styles =
    Css.asPairs >> style
