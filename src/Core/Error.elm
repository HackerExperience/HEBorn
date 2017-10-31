module Core.Error exposing (..)


type alias Error =
    ( String, String )


fakeTest : String -> Error
fakeTest =
    (,) "FAKE_TEST"


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
