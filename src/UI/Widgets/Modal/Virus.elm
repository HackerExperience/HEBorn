module UI.Widgets.Modal.Virus exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import UI.Widgets.Modal as Modal exposing (..)
import Game.Account.Bounces.Models as Bounces
import Game.Account.Database.Models as Database exposing (HackedServer)
import Game.Account.Finances.Models as Finances
    exposing
        ( AccountId
        , BitcoinAddress
        )
import Apps.VirusPanel.Config as App
import Apps.VirusPanel.Models as App
    exposing
        ( CollectBehavior(..)
        , CollectType(..)
        , setCollectingBounce
        , setCollectingAccount
        , setCollectingWallet
        , getCollectSelected
        )


modalSetActiveVirus :
    App.Config msg
    -> Database.HackedServer
    -> (Maybe String -> msg)
    -> msg
    -> msg
    -> App.Model
    -> Html msg
modalSetActiveVirus config server selectMsg okMsg cancelMsg model =
    let
        installedVirus =
            Database.getVirusInstalled server

        virusList =
            installedVirus
                |> Dict.values
                |> List.map Database.getVirusName

        activeVirus =
            model.selectedActiveVirus
                |> Maybe.andThen (flip Database.getVirus server)
                |> Maybe.map Database.getVirusName

        body =
            [ text "Select Active Virus: "
            , Modal.select virusList activeVirus selectMsg
            ]

        btns =
            okCancelButtons okMsg cancelMsg
    in
        modalFrame
            (Just "Virus Panel")
            body
            btns


modalCollect :
    App.Config msg
    -> CollectType
    -> (Maybe CollectBehavior -> msg)
    -> ( msg, msg )
    -> App.Model
    -> Html msg
modalCollect config type_ selectMsg ( okMsg, cancelMsg ) model =
    let
        selectList =
            collectSelect config type_ selectMsg model

        phrase =
            collectPhrase type_

        messagelessBody =
            (::) (br [] []) selectList

        body =
            text phrase
                |> flip (::) messagelessBody

        okButton =
            button (collectOkAttrs okMsg model.collectSelected) [ text "Ok" ]

        cancelButton =
            button [ onClick cancelMsg ] [ text "Cancel" ]

        btns =
            [ okButton
            , cancelButton
            ]
    in
        modalFrame
            (Just "Virus Panel")
            body
            btns



-- Helpers


bounceSelect :
    App.Config msg
    -> (Maybe CollectBehavior -> msg)
    -> App.Model
    -> Html msg
bounceSelect ({ bounces } as config) selectMsg model =
    let
        newBehavior id model =
            getCollectSelected <| setCollectingBounce id model

        noneOption =
            Html.option
                [ onClick <| selectMsg (newBehavior Nothing model) ]
                [ text "None" ]

        reducer id bounce acu =
            Html.option
                [ onClick <| selectMsg (newBehavior (Just id) model) ]
                [ text (Bounces.getNameWithBounce bounce) ]
                |> flip (::) acu
    in
        bounces
            |> Dict.foldr reducer []
            |> (::) noneOption
            |> Html.select []


accountSelect :
    App.Config msg
    -> (Maybe CollectBehavior -> msg)
    -> App.Model
    -> Html msg
accountSelect ({ finances } as config) selectMsg model =
    let
        newBehavior id model =
            getCollectSelected <| setCollectingAccount id model

        noneOption =
            Html.option
                [ onClick <| selectMsg (newBehavior Nothing model) ]
                [ text "None" ]

        reducer id acc acu =
            Html.option
                [ onClick <| selectMsg (newBehavior (Just id) model) ]
                [ text (Finances.accountToString id acc) ]
                |> flip (::) acu
    in
        finances
            |> Finances.getBankAccounts
            |> Dict.foldr reducer []
            |> (::) noneOption
            |> Html.select []


walletSelect :
    App.Config msg
    -> (Maybe CollectBehavior -> msg)
    -> App.Model
    -> Html msg
walletSelect ({ finances } as config) selectMsg model =
    let
        newBehavior id model =
            getCollectSelected <| setCollectingWallet id model

        noneOption =
            Html.option
                [ onClick <| selectMsg (newBehavior Nothing model) ]
                [ text "None" ]

        reducer address _ acu =
            Html.option
                [ onClick <| selectMsg (newBehavior (Just address) model) ]
                [ text address ]
                |> flip (::) acu
    in
        finances
            |> Finances.getBitcoinWallets
            |> Dict.foldr reducer []
            |> (::) noneOption
            |> Html.select []


collectSelect :
    App.Config msg
    -> CollectType
    -> (Maybe CollectBehavior -> msg)
    -> App.Model
    -> List (Html msg)
collectSelect config type_ selectMsg model =
    case type_ of
        MoneyVirus ->
            [ bounceSelect config selectMsg model
            , accountSelect config selectMsg model
            ]

        BitcoinVirus ->
            [ bounceSelect config selectMsg model
            , walletSelect config selectMsg model
            ]

        BothTypes ->
            [ bounceSelect config selectMsg model
            , accountSelect config selectMsg model
            , walletSelect config selectMsg model
            ]


collectPhrase : CollectType -> String
collectPhrase type_ =
    case type_ of
        MoneyVirus ->
            "Select your bounce and bank account"

        BitcoinVirus ->
            "Select your bounce and wallet"

        BothTypes ->
            "Select your bounce, bank account and wallet"


collectOkAttrs : msg -> Maybe CollectBehavior -> List (Attribute msg)
collectOkAttrs okMsg behavior =
    case behavior of
        Just (Money _ (Just accountId)) ->
            [ onClick okMsg ]

        Just (BTC _ (Just wallet)) ->
            [ onClick okMsg ]

        Just (Both _ (Just accountId) (Just wallet)) ->
            [ onClick okMsg ]

        _ ->
            [ disabled True ]
