module Game.Account.Requests.Logout exposing (logoutRequest)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Account.Models exposing (..)


type alias Data =
    Result () ()


logoutRequest : String -> ID -> FlagsSource a -> Cmd Data
logoutRequest token id flagsSrc =
    flagsSrc
        |> Requests.request_ (Topics.logout id) (encoder token)
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
