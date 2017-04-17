module Css.Utils exposing (..)

import Css exposing (..)


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
            "cubic-bezier(" ++ (toString a) ++ "," ++ (toString b) ++ "," ++ (toString c) ++ "," ++ (toString d) ++ ")"


transition : Float -> String -> Easing -> Mixin
transition time propertyName easing =
    property "transition" ((toString time) ++ "s " ++ (propertyName) ++ " " ++ (easingToString easing))



{- withAttrSelector attrName op value =
   Css.Preprocess.ExtendSelector
       ( Css.Structure.AttributeSelector
           ( Css.Helpers.toCssIdentifier attrName )
           op
           ( Css.Helpers.toCssIdentifier value )
       )
-}
--TODO: Fork elm-css


attrSelector parent attrName op value =
    selector ("." ++ parent ++ "[" ++ attrName ++ op ++ value ++ "]")
