module Apps.Browser.Pages.Bank.Models
    exposing
        ( Model
        , initialModel
        , Password
        , getTitle
        , State(..)
        )

import Game.Web.Types as Web
import Game.Meta.Types.Network exposing (NIP)
import Game.Account.Finances.Models exposing (AccountNumber, BankAccountData)
import Apps.Reference exposing (Reference)


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
    , password : Maybe Password
    }


type alias Password =
    String



-- Imposto é roubo


type State
    = Login
    | Main
    | Transfer


initialModel : Web.Url -> Web.BankContent -> Model
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
