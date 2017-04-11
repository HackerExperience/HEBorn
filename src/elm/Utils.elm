module Utils
    exposing
        (
            ..
        )

import Task
import Css exposing (..)


-- I know this is not how it's supposed to be done but until I get a better
-- grasp of Elm, it's good enough.


msgToCmd : a -> Cmd a
msgToCmd msg =
    Task.perform (always msg) (Task.succeed ())


boolToString : Bool -> String
boolToString bool =
    case bool of
        True ->
            "true"

        False ->
            "false"


maybeToString : Maybe String -> String
maybeToString maybe =
    case maybe of
        Just something ->
            something

        Nothing ->
            ""

-- Useful CSS

pseudoContent : String -> Mixin
pseudoContent v =
    property "content" v

type Easing
    = Ease
    | Linear
    | EaseIn
    | EaseOut
    | EaseInOut
    | CubicBezier Int Int Int Int

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
            "cubic-bezier("++(toString a)++","++(toString b)++","++(toString c)++","++(toString d)++")"

transition : Float -> String -> Easing -> Mixin
transition time propertyName easing =
    property "transition" ((toString time)++"s "++(propertyName)++" "++(easingToString easing))

-- Common CSS

flexContainerVert : Mixin
flexContainerVert =
    mixin
        [ displayFlex
        , flexDirection column
        ]

flexContainerHorz : Mixin
flexContainerHorz =
    mixin
        [ displayFlex
        , flexDirection row
        ]

globalShadow : Mixin
globalShadow =
    boxShadow5 (px 0) (px 0) (px 8) (px 1) (rgba 0 0 0 0.2)

emptyContent : Mixin
emptyContent =
   pseudoContent "''"