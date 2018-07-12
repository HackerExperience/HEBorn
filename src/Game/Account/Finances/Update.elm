module Game.Account.Finances.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Meta.Types.Desktop.Apps exposing (Requester)
import Game.Account.Finances.Config exposing (..)
import Game.Account.Finances.Models exposing (..)
import Game.Account.Finances.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleBankAccountClosed accountId ->
            handleBankAccountClosed accountId model

        HandleBankAccountUpdated accountId account ->
            handleBankAccountUpdated accountId account model


handleBankAccountClosed : AccountId -> Model -> UpdateResponse msg
handleBankAccountClosed accountId model =
    ( removeBankAccount accountId model, React.none )


handleBankAccountUpdated : AccountId -> BankAccount -> Model -> UpdateResponse msg
handleBankAccountUpdated accountId bankAccount model =
    ( insertBankAccount accountId bankAccount model, React.none )
