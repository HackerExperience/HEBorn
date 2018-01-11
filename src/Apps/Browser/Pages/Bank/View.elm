module Apps.Browser.Pages.Bank.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Html.Events exposing (..)
import Utils.Html.Events exposing (onKeyDown)
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.Bank.Config exposing (..)
import Apps.Browser.Pages.Bank.Models exposing (..)
import Apps.Browser.Pages.Bank.Messages exposing (..)
import Game.Account.Finances.Models exposing (AccountNumber)
import Game.Account.Finances.Shared exposing (toMoney)
import Game.Meta.Types.Network as Network


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    case model.bankState of
        Login ->
            viewLogin config model

        Main ->
            viewMain config model

        Transfer ->
            viewTransfer config model


viewLogin : Config msg -> Model -> Html msg
viewLogin config model =
    div []
        [ viewHeader model
        , viewLoginCointainer config model
        , viewFooter model
        ]


viewMain : Config msg -> Model -> Html msg
viewMain config model =
    div []
        [ viewHeader model
        , viewMainCointainer config model
        , viewFooter model
        ]


viewTransfer : Config msg -> Model -> Html msg
viewTransfer config model =
    div []
        [ viewHeader model
        , viewTransferCointainer config model
        , viewFooter model
        ]


viewHeader : Model -> Html msg
viewHeader model =
    div [] [ text model.title ]


viewFooter : Model -> Html msg
viewFooter model =
    div [] [ text model.title ]


viewLoginCointainer : Config msg -> Model -> Html msg
viewLoginCointainer ({ toMsg, onLogin } as config) model =
    div []
        [ input
            [ placeholder "Account Number"
            , onInput (toMsg << UpdateLoginField)
            ]
            []
        , br [] []
        , input
            [ placeholder "Password"
            , type_ "password"
            , onInput (toMsg << UpdatePasswordField)
            ]
            []
        , error model
        , br [] []
        , input
            (submitLoginAttr config model)
            []
        ]


viewMainCointainer : Config msg -> Model -> Html msg
viewMainCointainer { toMsg } model =
    let
        renderBalance model =
            case model.accountData of
                Just data ->
                    text <| toMoney data.balance

                Nothing ->
                    text ""
    in
        div []
            [ div []
                [ renderBalance model ]
            , div []
                []
            ]


viewTransferCointainer : Config msg -> Model -> Html msg
viewTransferCointainer ({ toMsg, onTransfer } as config) model =
    div []
        [ input
            [ placeholder "Bank IP"
            , onInput (toMsg << UpdateTransferBankField)
            ]
            []
        , br [] []
        , input
            [ placeholder "Account Number"
            , type_ "number"
            , onInput (toMsg << UpdateTransferAccountField)
            ]
            []
        , br [] []
        , input
            [ placeholder "Value"
            , type_ "number"
            , onInput (toMsg << UpdateTransferValueField)
            ]
            []
        , error model
        , input
            (submitTransferAttr config model)
            []
        ]


submitLoginAttr : Config msg -> Model -> List (Attribute msg)
submitLoginAttr { onLogin } model =
    let
        baseAttr =
            [ type_ "button" ]
    in
        case ( model.accountNum, model.password ) of
            ( Just login, Just password ) ->
                baseAttr ++ [ onSubmit <| onLogin model.nip login password ]

            _ ->
                baseAttr ++ [ disabled True ]


submitTransferAttr : Config msg -> Model -> List (Attribute msg)
submitTransferAttr { onTransfer } model =
    let
        baseAttr =
            [ type_ "button" ]
    in
        case
            ( model.accountNum
            , model.toBankTransfer
            , model.toAccountTransfer
            , model.password
            , model.transferValue
            )
        of
            ( Just fromAccount, Just toBank, Just toAccount, Just password, Just value ) ->
                [ onSubmit <| onTransfer model.nip fromAccount toBank toAccount password value ]
                    |> flip (++) baseAttr

            _ ->
                baseAttr ++ [ disabled True ]


error : Model -> Html msg
error model =
    case model.error of
        Just error ->
            div [] [ text error ]

        Nothing ->
            div [] []
