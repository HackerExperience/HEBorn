module Apps.VirusPanel.Models exposing (..)

import Dict exposing (Dict)
import Game.Meta.Types.Network exposing (NIP)
import Game.Account.Finances.Models as Finances
import Game.Account.Database.Models as Database
import Game.Account.Database.Shared exposing (..)


type MainTab
    = TabList
    | TabBotnet
    | TabCollect


type CollectType
    = MoneyVirus
    | BitcoinVirus
    | BothTypes


type CollectBehavior
    = -- Money (Maybe Bounce.ID) BankAccountId
      Money (Maybe String) (Maybe Finances.AccountId)
      -- BTC (Maybe Bounce.ID) BitcoinWalletAddress
    | BTC (Maybe String) (Maybe Finances.BitcoinAddress)
      -- Both (Maybe Bounce.ID) BankAccountId BitcoinWalletAddress
    | Both (Maybe String) (Maybe Finances.AccountId) (Maybe String)


type Error
    = CollectError CollectWithBankError


type ModalAction
    = ForCollect
    | ForSetActiveVirus NIP Database.HackedServer
    | ForError Error
    | ForCollectSuccessful


type Sorting
    = DefaultSort


type alias Model =
    { selected : MainTab
    , toCollectSelected : List NIP
    , modal : Maybe ModalAction
    , collectSelected : Maybe CollectBehavior
    , selectedActiveVirus : Maybe String
    }


name : String
name =
    "Virus Panel"


title : Model -> String
title model =
    name


icon : String
icon =
    "bug"


initialModel : Model
initialModel =
    { selected = TabList
    , toCollectSelected = []
    , modal = Nothing
    , collectSelected = Nothing
    , selectedActiveVirus = Nothing
    }


tabToString : MainTab -> String
tabToString tab =
    case tab of
        TabList ->
            "List"

        TabBotnet ->
            "B0TN3T"

        TabCollect ->
            "Collect"


setSelectedToCollect : Model -> List NIP -> Model
setSelectedToCollect model list =
    { model | toCollectSelected = list }


getSelectedToCollect : Model -> List NIP
getSelectedToCollect =
    .toCollectSelected


getCollectingBounce : Model -> Maybe String
getCollectingBounce model =
    case model.collectSelected of
        Just (Money bounce _) ->
            bounce

        Just (BTC bounce _) ->
            bounce

        Just (Both bounce _ _) ->
            bounce

        Nothing ->
            Nothing


getCollectingAccount : Model -> Maybe Finances.AccountId
getCollectingAccount model =
    case model.collectSelected of
        Just (Money _ account) ->
            account

        Just (BTC _ _) ->
            Nothing

        Just (Both _ account _) ->
            account

        Nothing ->
            Nothing


getCollectingWallet : Model -> Maybe String
getCollectingWallet model =
    case model.collectSelected of
        Just (Money _ _) ->
            Nothing

        Just (BTC _ wallet) ->
            wallet

        Just (Both _ _ wallet) ->
            wallet

        Nothing ->
            Nothing


getCollectSelected : Model -> Maybe CollectBehavior
getCollectSelected =
    .collectSelected


setCollectingBounce : Maybe String -> Model -> Model
setCollectingBounce bounce model =
    case model.collectSelected of
        Just (Money _ accountId) ->
            { model | collectSelected = Just (Money bounce accountId) }

        Just (BTC _ wallet) ->
            { model | collectSelected = Just (BTC bounce wallet) }

        Just (Both _ accountId wallet) ->
            { model | collectSelected = Just (Both bounce accountId wallet) }

        Nothing ->
            model


setCollectingAccount : Maybe Finances.AccountId -> Model -> Model
setCollectingAccount accountId model =
    case model.collectSelected of
        Just (Money bounce _) ->
            { model | collectSelected = Just (Money bounce accountId) }

        Just (BTC bounce wallet) ->
            { model | collectSelected = Just (BTC bounce wallet) }

        Just (Both bounce _ wallet) ->
            { model | collectSelected = Just (Both bounce accountId wallet) }

        Nothing ->
            model


setCollectingWallet : Maybe String -> Model -> Model
setCollectingWallet wallet model =
    case model.collectSelected of
        Just (Money bounce accountId) ->
            { model | collectSelected = Just (Money bounce accountId) }

        Just (BTC bounce _) ->
            { model | collectSelected = Just (BTC bounce wallet) }

        Just (Both bounce accountId _) ->
            { model | collectSelected = Just (Both bounce accountId wallet) }

        Nothing ->
            model


dropModal : Model -> Model
dropModal model =
    { model | modal = Nothing }
