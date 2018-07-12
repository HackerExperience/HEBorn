module Apps.Browser.Pages.Bank.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Html.Events exposing (..)
import Game.Bank.Models as Bank
import Apps.Browser.Pages.Bank.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.Bank.Config exposing (..)
import Apps.Browser.Pages.Bank.Models exposing (..)
import Apps.Browser.Pages.Bank.Messages exposing (..)
import Game.Bank.Shared exposing (toMoney)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    case model.state of
        Login _ ->
            viewLogin config model

        Main ->
            viewMain config model

        Loading ->
            viewLoading config model

        Transfer _ ->
            viewTransfer config model

        TransferSuccess ->
            viewTransferSuccess config model


viewLogin : Config msg -> Model -> Html msg
viewLogin config model =
    div [ class [ MainContainer ] ]
        [ viewHeader model
        , viewLoginForm config model
        , viewFooter model
        ]


viewLoading : Config msg -> Model -> Html msg
viewLoading config model =
    div [ class [ MainContainer ] ] [ text "Loading..." ]


viewTransferSuccess : Config msg -> Model -> Html msg
viewTransferSuccess config model =
    div [ class [ MainContainer ] ] [ text "Transfer started." ]


viewMain : Config msg -> Model -> Html msg
viewMain config model =
    div [ class [ MainContainer ] ]
        [ viewHeader model
        , viewMainCointainer config model
        , viewFooter model
        ]


viewTransfer : Config msg -> Model -> Html msg
viewTransfer config model =
    div [ class [ MainContainer ] ]
        [ viewHeader model
        , viewTransferForm config model
        , viewFooter model
        ]


viewHeader : Model -> Html msg
viewHeader model =
    div [ class [ Header ] ] [ text model.title ]


viewFooter : Model -> Html msg
viewFooter model =
    div [ class [ Footer ] ] [ text model.title ]


viewLoginForm : Config msg -> Model -> Html msg
viewLoginForm ({ toMsg, onLogin } as config) model =
    let
        passwordAttr =
            [ placeholder "Password"
            , type_ "password"
            , onInput (UpdatePasswordField >> toMsg)
            , class [ Input ]
            ]
                |> (++) (renderPasswordValue model)

        loginAttr =
            [ placeholder "Account Number"
            , onInput (UpdateLoginField >> toMsg)
            , class [ Input ]
            ]
                |> (++) (renderLoginValue model)

        login =
            input loginAttr []

        password =
            input passwordAttr []
    in
        div [ class [ MiddleContainer ] ]
            [ Html.form [ class [ LoginForm ], action "javascript:void(0);" ]
                [ login
                , br [] []
                , password
                , div [] [ error model ]
                , br [] []
                , input
                    (submitLoginAttr config model)
                    []
                ]
            ]


renderBalance : Config msg -> Model -> Html msg
renderBalance config model =
    model
        |> (.sessionId)
        |> Maybe.andThen ((flip Bank.getSession) config.bank)
        |> Maybe.map (.accountCache)
        |> Maybe.map (.balance)
        |> Maybe.map (\a -> "Available USD: " ++ (toMoney a))
        |> Maybe.withDefault "Balance is not Availiable"
        |> text

viewMainCointainer : Config msg -> Model -> Html msg
viewMainCointainer ({ toMsg } as config) model =
    div [ class [ MiddleContainer ] ]
        [ div [ class [ BalanceContainer ] ]
            [ renderBalance config model ]
        , div [ class [ ActionsContainer ] ]
            [ button (buttonCPAttr config model) [ text "Change Password" ]
            , button (buttonTransferAttr config model) [ text "Transfer" ]
            ]
        ]


viewTransferForm : Config msg -> Model -> Html msg
viewTransferForm ({ toMsg, onTransfer } as config) model =
    let
        bankIPAttr =
            [ placeholder "Bank IP"
            , onInput (toMsg << UpdateTransferBankField)
            ]
                |> (++) (renderToTransferBank model)

        accountAttr info =
            [ placeholder "Account Number"
            , info.destinyAccount
                |> Maybe.map toString
                |> Maybe.withDefault ""
                |> value
            , onInput (toMsg << UpdateTransferAccountField)
            ]

        valueAttr info =
            [ placeholder "Value"
            , info.value
                |> Maybe.map toString
                |> Maybe.withDefault ""
                |> value
            , onInput (toMsg << UpdateTransferValueField)
            ]
    in
        case model.state of
            Transfer info ->
                div [ class [ MiddleContainer ] ]
                    [ Html.form 
                        [ class [ TransferForm ]
                        , action "javascript:void(0);" 
                        ]
                        [ input bankIPAttr []
                        , br [] []
                        , input (accountAttr info) []
                        , br [] []
                        , input (valueAttr info) []
                        , div [] [ error model ]
                        , br [] []
                        , input (submitTransferAttr config model) []
                        ]
                    ]

            _ ->
                text ""


buttonCPAttr : Config msg -> Model -> List (Attribute msg)
buttonCPAttr config model =
    case model.sessionId of
        Just sessionId ->
            [ name "Change Password"
            , onClick <| config.onChangePassword sessionId
            ]

        Nothing ->
            [ disabled True ]

buttonTransferAttr : Config msg -> Model -> List (Attribute msg)
buttonTransferAttr {toMsg} model =
    case model.sessionId of
        Just sessionId ->
            [ name "Transfer"
            , SetTransfer
                |> toMsg
                |> onClick 
            ]

        Nothing ->
            [ disabled True ]


submitButtonBaseAttr : List (Attribute msg)
submitButtonBaseAttr =
    [ type_ "submit"
    , value "Submit"
    ]


submitLoginAttr : Config msg -> Model -> List (Attribute msg)
submitLoginAttr { onLogin, toMsg, batchMsg } model =
    let
        applier login password =
            [ onLogin ( model.atmId, login ) password
            , toMsg SetLoading
            ]
                |> batchMsg
                |> onClick
                |> flip (::) submitButtonBaseAttr

        ( login, password ) =
            case model.state of
                Login info ->
                    (,) info.login info.password

                _ ->
                    (,) Nothing Nothing
    in
        case Maybe.map2 applier login password of
            Just attr ->
                attr

            Nothing ->
                (disabled True) :: submitButtonBaseAttr


submitTransferAttr : Config msg -> Model -> List (Attribute msg)
submitTransferAttr { onTransfer } model =
    let
        applier sessionId accNum bankIp value =
            onTransfer sessionId bankIp accNum value
                |> onClick
                |> flip (::) submitButtonBaseAttr

        ( sessionId, accNum, bankIp, value ) =
            case model.state of
                Transfer info ->
                    ( model.sessionId
                    , info.destinyAccount
                    , info.destinyBank
                    , info.value
                    )

                _ ->
                    ( model.sessionId, Nothing, Nothing, Nothing )
    in
        case Maybe.map4 applier sessionId accNum bankIp value of
            Just attr ->
                attr

            Nothing ->
                (disabled True) :: submitButtonBaseAttr


error : Model -> Html msg
error model =
    case model.state of
        Login info ->
            text (Maybe.withDefault "" info.error)

        Transfer info ->
            text (Maybe.withDefault "" info.error)

        _ ->
            text ""


renderToTransferBank : Model -> List (Attribute msg)
renderToTransferBank model =
    case model.state of
        Transfer info ->
            case info.destinyBank of
                Just destinyBank ->
                    [ value destinyBank ]

                Nothing ->
                    []

        _ ->
            []


renderPasswordValue : Model -> List (Attribute msg)
renderPasswordValue model =
    case model.state of
        Login info ->
            case info.password of
                Just password ->
                    [ value password ]

                Nothing ->
                    []

        _ ->
            []


renderLoginValue : Model -> List (Attribute msg)
renderLoginValue model =
    case model.state of
        Login info ->
            [ value <| Maybe.withDefault "" (Maybe.map toString info.login) ]

        _ ->
            []
