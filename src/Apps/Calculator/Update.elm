module Apps.Calculator.Update exposing (update)

import Utils.React as React exposing (React)
import Apps.Calculator.Config exposing (..)
import Apps.Calculator.Models exposing (..)
import Apps.Calculator.Messages exposing (..)
import Char


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        Input n ->
            onInput n model

        Sum ->
            onSum model

        Subtract ->
            onSubtract model

        Divide ->
            onDivide model

        Multiply ->
            onMultiply model

        Percent ->
            onPercent model

        Sqrt ->
            onSqrt model

        Comma ->
            onComma model

        CleanAll ->
            onCleanAll model

        Backspace ->
            onBackspace model

        Equal ->
            onEqual model

        KeyMsg code ->
            onKeyMsg code model


onInput : String -> Model -> UpdateResponse msg
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
                let
                    model_ =
                        { model | display = Typing n }
                in
                    ( model_, React.none )

            Typing x ->
                let
                    model_ =
                        { model | display = createTyping x n }
                in
                    ( model_, React.none )

            Add x y ->
                case y of
                    Typing a ->
                        let
                            model_ =
                                { model | display = Add x <| createTyping a n }
                        in
                            ( model_, React.none )

                    _ ->
                        ( model, React.none )

            Sub x y ->
                case y of
                    Typing a ->
                        let
                            model_ =
                                { model | display = Sub x <| createTyping a n }
                        in
                            ( model_, React.none )

                    _ ->
                        ( model, React.none )

            Div x y ->
                case y of
                    Typing a ->
                        let
                            model_ =
                                { model | display = Div x <| createTyping a n }
                        in
                            ( model_, React.none )

                    _ ->
                        ( model, React.none )

            Mul x y ->
                case y of
                    Typing a ->
                        let
                            model_ =
                                { model | display = Mul x <| createTyping a n }
                        in
                            ( model_, React.none )

                    _ ->
                        ( model, React.none )

            _ ->
                ( model, React.none )


onKeyMsg : Int -> Model -> UpdateResponse msg
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
            ( model, React.none )


onSum : Model -> UpdateResponse msg
onSum model =
    case model.display of
        Typing x ->
            let
                model_ =
                    { model | display = Add x (Typing "0") }
            in
                ( model_, React.none )

        _ ->
            ( model, React.none )


onSubtract : Model -> UpdateResponse msg
onSubtract model =
    case model.display of
        Typing x ->
            let
                model_ =
                    { model | display = Sub x (Typing "0") }
            in
                ( model_, React.none )

        _ ->
            ( model, React.none )


onDivide : Model -> UpdateResponse msg
onDivide model =
    case model.display of
        Typing x ->
            let
                model_ =
                    { model | display = Div x (Typing "0") }
            in
                ( model_, React.none )

        _ ->
            ( model, React.none )


onMultiply : Model -> UpdateResponse msg
onMultiply model =
    case model.display of
        Typing x ->
            let
                model_ =
                    { model | display = Mul x (Typing "0") }
            in
                ( model_, React.none )

        _ ->
            ( model, React.none )


onPercent : Model -> UpdateResponse msg
onPercent model =
    applyPercent model


onSqrt : Model -> UpdateResponse msg
onSqrt model =
    applySqrt model


onComma : Model -> UpdateResponse msg
onComma model =
    inputComma model


onCleanAll : Model -> UpdateResponse msg
onCleanAll model =
    ( { model | display = Typing "0" }, React.none )


onBackspace : Model -> UpdateResponse msg
onBackspace model =
    inputBackspace model


onEqual : Model -> UpdateResponse msg
onEqual model =
    applyEquals model


inputComma : Model -> UpdateResponse msg
inputComma model =
    case model.display of
        Typing a ->
            let
                model_ =
                    { model | display = Typing a }
            in
                ( model_, React.none )

        Add n (Typing a) ->
            let
                model_ =
                    { model | display = Add n (Typing <| canInputComma a) }
            in
                ( model_, React.none )

        Sub n (Typing a) ->
            let
                model_ =
                    { model | display = Sub n (Typing <| canInputComma a) }
            in
                ( model_, React.none )

        Div n (Typing a) ->
            let
                model_ =
                    { model | display = Div n (Typing <| canInputComma a) }
            in
                ( model_, React.none )

        Mul n (Typing a) ->
            let
                model_ =
                    { model | display = Mul n (Typing <| canInputComma a) }
            in
                ( model_, React.none )

        Pow n (Typing a) ->
            let
                model_ =
                    { model | display = Pow n (Typing <| canInputComma a) }
            in
                ( model_, React.none )

        _ ->
            ( model, React.none )


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


inputBackspace : Model -> UpdateResponse msg
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
                let
                    model_ =
                        { model | display = drop a }
                in
                    ( model_, React.none )

            Add a (Typing b) ->
                let
                    model_ =
                        { model | display = Add a (drop b) }
                in
                    ( model_, React.none )

            Sub a (Typing b) ->
                let
                    model_ =
                        { model | display = Sub a (drop b) }
                in
                    ( model_, React.none )

            Div a (Typing b) ->
                let
                    model_ =
                        { model | display = Div a (drop b) }
                in
                    ( model_, React.none )

            Mul a (Typing b) ->
                let
                    model_ =
                        { model | display = Mul a (drop b) }
                in
                    ( model_, React.none )

            Pow a (Typing b) ->
                let
                    model_ =
                        { model | display = Pow a (drop b) }
                in
                    ( model_, React.none )

            _ ->
                ( model, React.none )


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


applyEquals : Model -> UpdateResponse msg
applyEquals model =
    case model.display of
        Add a b ->
            case b of
                Typing m ->
                    let
                        model_ =
                            { model | display = Typing (resultString a m (+)) }
                    in
                        ( model_, React.none )

                _ ->
                    ( model, React.none )

        Sub a b ->
            case b of
                Typing m ->
                    let
                        model_ =
                            { model | display = Typing (resultString a m (-)) }
                    in
                        ( model_, React.none )

                _ ->
                    ( model, React.none )

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

                        model_ =
                            if (by_zero m) then
                                { model | display = DivideBy0 }
                            else
                                { model | display = Typing (resultString a m (/)) }
                    in
                        ( model_, React.none )

                _ ->
                    ( model, React.none )

        Mul a b ->
            case b of
                Typing m ->
                    let
                        model_ =
                            { model | display = Typing (resultString a m (*)) }
                    in
                        ( model_, React.none )

                _ ->
                    ( model, React.none )

        Pow a b ->
            case b of
                Typing m ->
                    let
                        model_ =
                            { model | display = Typing (resultString a m (^)) }
                    in
                        ( model_, React.none )

                _ ->
                    ( model, React.none )

        IsNotANumber ->
            ( model, React.none )

        DivideBy0 ->
            ( model, React.none )

        InvalidOperation ->
            ( model, React.none )

        _ ->
            ( model, React.none )


applyPercent : Model -> UpdateResponse msg
applyPercent model =
    let
        b_side x y =
            Typing (resultString (resultString x "100" (/)) y (*))
    in
        case model.display of
            Typing x ->
                ( model, React.none )

            Add x (Typing y) ->
                let
                    model_ =
                        { model | display = Add x (b_side x y) }
                in
                    ( model_, React.none )

            Sub x (Typing y) ->
                let
                    model_ =
                        { model | display = Sub x (b_side x y) }
                in
                    ( model_, React.none )

            Div x (Typing y) ->
                let
                    model_ =
                        { model | display = Div x (b_side x y) }
                in
                    ( model_, React.none )

            Mul x (Typing y) ->
                let
                    model_ =
                        { model | display = Mul x (b_side x y) }
                in
                    ( model_, React.none )

            Pow x (Typing y) ->
                let
                    model_ =
                        { model | display = Pow x (b_side x y) }
                in
                    ( model_, React.none )

            _ ->
                ( model, React.none )


applySqrt : Model -> UpdateResponse msg
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
                let
                    model_ =
                        { model | display = value x }
                in
                    ( model_, React.none )

            Add x (Typing y) ->
                let
                    model_ =
                        { model | display = value y }
                in
                    ( model_, React.none )

            Sub x (Typing y) ->
                let
                    model_ =
                        { model | display = value y }
                in
                    ( model_, React.none )

            Div x (Typing y) ->
                let
                    model_ =
                        { model | display = value y }
                in
                    ( model_, React.none )

            Mul x (Typing y) ->
                let
                    model_ =
                        { model | display = value y }
                in
                    ( model_, React.none )

            Pow x (Typing y) ->
                let
                    model_ =
                        { model | display = value y }
                in
                    ( model_, React.none )

            _ ->
                ( model, React.none )
