module Game.Account.Requests.SignOut exposing (signOutRequest)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Account.Models exposing (..)


type alias Data =
    Result () ()


signOutRequest : String -> ID -> FlagsSource a -> Cmd Data
signOutRequest token id flagsSrc =
    flagsSrc
        |> Requests.request_ (Topics.accountLogout id) (encoder token)
        |> Cmd.map (uncurry receiver)



-- internals


encoder : String -> Value
encoder token =
    Encode.object
        [ ( "token", Encode.string token ) ]


receiver : Code -> Value -> Result () ()
receiver code _ =
    case code of
        OkCode ->
            Ok ()

        _ ->
            Err ()
