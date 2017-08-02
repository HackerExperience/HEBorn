module Css.Utils exposing (..)

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


type Condition
    = EQ String String


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
            a ++ "=" ++ b


withAttribute : Condition -> List Style -> Style
withAttribute cond =
    pseudoClass
        ("not(foo)[" ++ (conditionToString cond) ++ "]")


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
