module Apps.Calculator.View exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Apps.Calculator.Config exposing (..)
import Apps.Calculator.Models exposing (..)
import Apps.Calculator.Messages exposing (Msg(..))
import Apps.Calculator.Resources exposing (..)
import Core.Error as Error


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    let
        addBtn =
            btn config [ NormalBtn ] Sum "+"

        divideBtn =
            btn config [ NormalBtn ] Divide "/"

        subtractBtn =
            btn config [ NormalBtn ] Subtract "-"

        multiplyBtn =
            btn config [ NormalBtn ] Multiply "*"

        squarerootBtn =
            btn config [ NormalBtn ] Sqrt "√"

        applyBtn =
            btn config [ ApplyBtn ] Equal "="

        percentBtn =
            btn config [ NormalBtn ] Percent "%"

        commaBtn =
            btn config [ NormalSubBtn ] Comma "."

        clearallBtn =
            btn config [ DoubleWidthBtn ] CleanAll "C"

        bkspaceBtn =
            btn config [ DoubleWidthBtn ] Backspace "BS"

        numBtn x =
            let
                string =
                    toString x
            in
                if x <= 3 && x /= 0 then
                    btn config [ NormalSubBtn ] (Input string) string
                else if x == 0 then
                    btn config [ ZeroBtn ] (Input string) string
                else
                    btn config [ NormalBtn ] (Input string) string
    in
        div [ class [ MainContainer ] ]
            [ div [ class [ DisplayContainer ] ]
                [ text (renderTyping model.display) ]
            , div [ class [ ButtonsContainer ] ]
                [ clearallBtn
                , bkspaceBtn
                , percentBtn
                , divideBtn
                , multiplyBtn
                , subtractBtn
                , numBtn 7
                , numBtn 8
                , numBtn 9
                , addBtn
                , numBtn 4
                , numBtn 5
                , numBtn 6
                , squarerootBtn
                , div [ class [ ButtonsContainerSub ] ]
                    [ numBtn 1
                    , numBtn 2
                    , numBtn 3
                    , numBtn 0
                    , commaBtn
                    ]
                , applyBtn
                ]
            ]


btn : Config msg -> List Classes -> Msg -> String -> Html msg
btn { toMsg } class_ action label =
    let
        attrib =
            [ class class_
            , onClick (toMsg action)
            ]
    in
        button
            attrib
            [ text label ]


renderTyping : Operator -> String
renderTyping op =
    case op of
        Typing x ->
            x

        Add x (Typing y) ->
            y

        Sub x (Typing y) ->
            y

        Div x (Typing y) ->
            y

        Mul x (Typing y) ->
            y

        Pow x (Typing y) ->
            y

        IsNotANumber ->
            "Is not a Number"

        DivideBy0 ->
            "Divided by 0"

        InvalidOperation ->
            "Invalid Operation"

        _ ->
            "Error"
