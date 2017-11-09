module Apps.Calculator.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Utils.Html exposing (spacer)
import UI.ToString exposing (timestampToFullData)
import Game.Data as Game
import Apps.Calculator.Models exposing (..)
import Apps.Calculator.Messages exposing (Msg(..))
import Apps.Calculator.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "hecalc"


view : Game.Data -> Model -> Html Msg
view data model =
    render model


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



--renderStoredNum : Operator -> String
--renderStoredNum model =
--    case model of
--        Add x (Typing y z) ->
--            toString x
--        Sub x (Typing y z) ->
--            toString x
--        Div x (Typing y z) ->
--            toString x
--        Mul x (Typing y z) ->
--            toString x
--        Pow x (Typing y z) ->
--            toString x
--        _ ->
--            ""


render : Model -> Html Msg
render model =
    let
        genBtn class_ action label =
            let
                attrib =
                    [ class class_
                    , onClick action
                    ]
            in
                button
                    attrib
                    [ text label ]

        addBtn =
            genBtn [ NormalBtn ] Sum "+"

        divideBtn =
            genBtn [ NormalBtn ] Divide "/"

        subtractBtn =
            genBtn [ NormalBtn ] Subtract "-"

        multiplyBtn =
            genBtn [ NormalBtn ] Multiply "*"

        squarerootBtn =
            genBtn [ NormalBtn ] Sqrt "√"

        applyBtn =
            genBtn [ ApplyBtn ] Equal "="

        percentBtn =
            genBtn [ NormalBtn ] Percent "%"

        commaBtn =
            genBtn [ NormalSubBtn ] Comma "."

        clearallBtn =
            genBtn [ DoubleWidthBtn ] CleanAll "C"

        bkspaceBtn =
            genBtn [ DoubleWidthBtn ] Backspace "BS"

        numBtn string =
            let
                x =
                    case (String.toInt string) of
                        Ok y ->
                            y

                        Err msg ->
                            Debug.log
                                "Die monster you don't belong in this world"
                                10
            in
                if x /= -1 then
                    if x <= 3 && x /= 0 then
                        genBtn [ NormalSubBtn ] (Input string) string
                    else if x == 0 then
                        genBtn [ ZeroBtn ] (Input string) string
                    else
                        genBtn [ NormalBtn ] (Input string) string
                else
                    text "Die Monster you don't belong in this world"
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
                , numBtn "7"
                , numBtn "8"
                , numBtn "9"
                , addBtn
                , numBtn "4"
                , numBtn "5"
                , numBtn "6"
                , squarerootBtn
                , div [ class [ ButtonsContainerSub ] ]
                    [ numBtn "1"
                    , numBtn "2"
                    , numBtn "3"
                    , numBtn "0"
                    , commaBtn
                    ]
                , applyBtn
                ]
            ]
