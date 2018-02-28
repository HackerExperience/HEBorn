module Apps.Browser.Pages.Bank.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        , State(..)
        )

import Game.Meta.Types.Network.Site as Site
import Game.Meta.Types.Network exposing (NIP)
import Game.Account.Finances.Models exposing (AccountNumber)
import Game.Account.Finances.Shared exposing (BankAccountData)


type alias Model =
    { title : String
    , nip : NIP
    , loggedIn : Bool
    , bankState : State
    , error : Maybe String
    , accountData : Maybe BankAccountData
    , toBankTransfer : Maybe NIP
    , toAccountTransfer : Maybe AccountNumber
    , accountNum : Maybe AccountNumber
    , transferValue : Maybe Int
    , password : Maybe String
    }



-- Imposto é roubo


type State
    = Login
    | Main
    | Transfer


initialModel : Site.Url -> Site.BankContent -> Model
initialModel url content =
    { title = content.title
    , nip = content.nip
    , loggedIn = False
    , bankState = Login
    , error = Nothing
    , accountData = Nothing
    , toBankTransfer = Nothing
    , toAccountTransfer = Nothing
    , accountNum = Nothing
    , transferValue = Nothing
    , password = Nothing
    }


getTitle : Model -> String
getTitle { title } =
    title ++ " Bank"
