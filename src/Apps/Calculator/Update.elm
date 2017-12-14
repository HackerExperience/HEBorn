module Apps.Calculator.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Apps.Calculator.Models exposing (..)
import Game.Data as Game
import Apps.Calculator.Messages as Calculator exposing (Msg(..))
import Char


update :
    Game.Data
    -> Calculator.Msg
    -> Model
    -> ( Model, Cmd Calculator.Msg, Dispatch )
update data msg model =
    case msg of
        Input n ->
            onInput n model
                |> Update.fromModel

        Sum ->
            onSum model
                |> Update.fromModel

        Subtract ->
            onSubtract model
                |> Update.fromModel

        Divide ->
            onDivide model
                |> Update.fromModel

        Multiply ->
            onMultiply model
                |> Update.fromModel

        Percent ->
            onPercent model
                |> Update.fromModel

        Sqrt ->
            onSqrt model
                |> Update.fromModel

        Comma ->
            onComma model
                |> Update.fromModel

        CleanAll ->
            onCleanAll model
                |> Update.fromModel

        Backspace ->
            onBackspace model
                |> Update.fromModel

        Equal ->
            onEqual model
                |> Update.fromModel

        KeyMsg code ->
            onKeyMsg code model
                |> Update.fromModel

        MenuMsg _ ->
            model
                |> Update.fromModel


onInput : String -> Model -> Model
onInput n model =
    let
        createTyping x y =
            if x == "0" then
                Typing y
            else if (String.length x) >= 17 then
                Typing x
            else
                Typing (x ++ y)
    in
        case model.display of
            None ->
                { model | display = Typing n }

            Typing x ->
                { model | display = createTyping x n }

            Add x y ->
                case y of
                    Typing a ->
                        { model | display = Add x <| createTyping a n }

                    _ ->
                        model

            Sub x y ->
                case y of
                    Typing a ->
                        { model | display = Sub x <| createTyping a n }

                    _ ->
                        model

            Div x y ->
                case y of
                    Typing a ->
                        { model | display = Div x <| createTyping a n }

                    _ ->
                        model

            Mul x y ->
                case y of
                    Typing a ->
                        { model | display = Mul x <| createTyping a n }

                    _ ->
                        model

            _ ->
                model


onKeyMsg : Int -> Model -> Model
onKeyMsg code model =
    let
        getStringfromChar x =
            String.fromChar <| Char.fromCode x

        -- Codes 48 to 57 are normal numbers codes
        -- Codes 96 to 105 are numpad codes
        isNumber =
            (code >= 48 && code <= 57) || (code >= 96 && code <= 105)

        -- Code 13 refers to the Return Key
        isReturn =
            (code == 13)

        -- Code 107 refers to the Plus Signal Key
        isAdd =
            (code == 107)

        -- Code 109 refers to the Minus Signal Key
        isSubtract =
            (code == 109)

        -- Code 106 refers to the Asterisk Key
        isMultiply =
            (code == 106)

        -- Code 191 refers to the Divide Key
        isDivide =
            (code == 191)

        -- Code 8 refers to the Backspace Key
        isBackspace =
            (code == 8)

        -- Code 188 refers to the Comma key and 190 to the Dot Key
        -- Code 110 refers to Numpad's Decimal Key
        isComma =
            (code == 188 || code == 190 || code == 110)

        code_ =
            if code <= 57 then
                code
            else
                code - 48
    in
        --If Char code is between 48 and 57 (in other words 0 and 9)
        if isNumber then
            onInput (getStringfromChar code_) model
        else if isReturn then
            onEqual model
        else if isAdd then
            onSum model
        else if isSubtract then
            onSubtract model
        else if isMultiply then
            onMultiply model
        else if isDivide then
            onDivide model
        else if isBackspace then
            onBackspace model
        else if isComma then
            onComma model
        else
            model


onSum : Model -> Model
onSum model =
    case model.display of
        Typing x ->
            { model | display = Add x (Typing "0") }

        _ ->
            model


onSubtract : Model -> Model
onSubtract model =
    case model.display of
        Typing x ->
            { model | display = Sub x (Typing "0") }

        _ ->
            model


onDivide : Model -> Model
onDivide model =
    case model.display of
        Typing x ->
            { model | display = Div x (Typing "0") }

        _ ->
            model


onMultiply : Model -> Model
onMultiply model =
    case model.display of
        Typing x ->
            { model | display = Mul x (Typing "0") }

        _ ->
            model


onPercent : Model -> Model
onPercent model =
    applyPercent model


onSqrt : Model -> Model
onSqrt model =
    applySqrt model


onComma : Model -> Model
onComma model =
    inputComma model


onCleanAll : Model -> Model
onCleanAll model =
    { model | display = Typing "0" }


onBackspace : Model -> Model
onBackspace model =
    inputBackspace model


onEqual : Model -> Model
onEqual model =
    applyEquals model


inputComma : Model -> Model
inputComma model =
    case model.display of
        Typing a ->
            { model | display = Typing a }

        Add n (Typing a) ->
            { model | display = Add n (Typing <| canInputComma a) }

        Sub n (Typing a) ->
            { model | display = Sub n (Typing <| canInputComma a) }

        Div n (Typing a) ->
            { model | display = Div n (Typing <| canInputComma a) }

        Mul n (Typing a) ->
            { model | display = Mul n (Typing <| canInputComma a) }

        Pow n (Typing a) ->
            { model | display = Pow n (Typing <| canInputComma a) }

        _ ->
            model


canInputComma : String -> String
canInputComma str =
    let
        canInputCommaHelper str =
            if (String.length str) > 0 then
                str ++ "."
            else
                str
    in
        if String.contains "." str then
            str
        else
            canInputCommaHelper str


inputBackspace : Model -> Model
inputBackspace model =
    let
        drop x =
            if (String.length x) > 1 then
                Typing (String.dropRight 1 x)
            else if (String.length x) == 1 then
                Typing "0"
            else
                Typing x
    in
        case model.display of
            Typing a ->
                { model | display = drop a }

            Add a (Typing b) ->
                { model | display = Add a (drop b) }

            Sub a (Typing b) ->
                { model | display = Sub a (drop b) }

            Div a (Typing b) ->
                { model | display = Div a (drop b) }

            Mul a (Typing b) ->
                { model | display = Mul a (drop b) }

            Pow a (Typing b) ->
                { model | display = Pow a (drop b) }

            _ ->
                model


resultString : String -> String -> (Float -> Float -> Float) -> String
resultString x y z =
    case (String.toFloat x) of
        Ok a ->
            case (String.toFloat y) of
                Ok b ->
                    toString (z a b)

                Err msg ->
                    msg

        Err msg ->
            msg


applyEquals : Model -> Model
applyEquals model =
    case model.display of
        Add a b ->
            case b of
                Typing m ->
                    { model | display = Typing (resultString a m (+)) }

                _ ->
                    model

        Sub a b ->
            case b of
                Typing m ->
                    { model | display = Typing (resultString a m (-)) }

                _ ->
                    model

        Div a b ->
            case b of
                Typing m ->
                    let
                        by_zero x =
                            case (String.toFloat x) of
                                Ok y ->
                                    if y == 0.0 then
                                        True
                                    else
                                        False

                                Err msg ->
                                    True
                    in
                        if (by_zero m) then
                            { model | display = DivideBy0 }
                        else
                            { model | display = Typing (resultString a m (/)) }

                _ ->
                    model

        Mul a b ->
            case b of
                Typing m ->
                    { model | display = Typing (resultString a m (*)) }

                _ ->
                    model

        Pow a b ->
            case b of
                Typing m ->
                    { model | display = Typing (resultString a m (^)) }

                _ ->
                    model

        IsNotANumber ->
            model

        DivideBy0 ->
            model

        InvalidOperation ->
            model

        _ ->
            model


applyPercent : Model -> Model
applyPercent model =
    let
        b_side x y =
            Typing (resultString (resultString x "100" (/)) y (*))
    in
        case model.display of
            Typing x ->
                model

            Add x (Typing y) ->
                { model | display = Add x (b_side x y) }

            Sub x (Typing y) ->
                { model | display = Sub x (b_side x y) }

            Div x (Typing y) ->
                { model | display = Div x (b_side x y) }

            Mul x (Typing y) ->
                { model | display = Mul x (b_side x y) }

            Pow x (Typing y) ->
                { model | display = Pow x (b_side x y) }

            _ ->
                model


applySqrt : Model -> Model
applySqrt model =
    let
        doSqrt str =
            case (String.toFloat str) of
                Ok x ->
                    toString (sqrt x)

                Err msg ->
                    msg

        value x =
            Typing (doSqrt x)
    in
        case model.display of
            Typing x ->
                { model | display = value x }

            Add x (Typing y) ->
                { model | display = value y }

            Sub x (Typing y) ->
                { model | display = value y }

            Div x (Typing y) ->
                { model | display = value y }

            Mul x (Typing y) ->
                { model | display = value y }

            Pow x (Typing y) ->
                { model | display = value y }

            _ ->
                model
