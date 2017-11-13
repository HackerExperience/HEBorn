module Core.Error exposing (..)

import Requests.Types exposing (Code(..))


type alias Error =
    ( String, String )


fakeTest : String -> Error
fakeTest =
    (,) "FAKE_TEST"


request : String -> String -> Error
request name msg =
    porra <| ("Couldn't decode '" ++ name ++ "' request response:\n" ++ msg)


requestCode : String -> a -> Error
requestCode name code =
    porra <|
        ("Unexpected '"
            ++ name
            ++ "' request error code '"
            ++ toString code
            ++ "''"
        )


astralProj : String -> Error
astralProj =
    (,) "WTF_ASTRAL_PROJECTION"


impossible : String -> Error
impossible =
    (,) "WTF_IMPOSSIBLE"


neeiae : String -> Error
neeiae =
    (,) "ERROR_NONEXISTINGENDPOINT_ISACTIVEENDPOINT"


porra : String -> Error
porra =
    (,) "ERR_PORRA_RENATO"
