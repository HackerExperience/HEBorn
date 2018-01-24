module Core.Error exposing (..)


type alias Error =
    ( String, String )


fakeTest : String -> Error
fakeTest =
    -- Dummy error code
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
    -- For missing ACTIVE server or gateway
    (,) "WTF_ASTRAL_PROJECTION"


impossible : String -> Error
impossible =
    -- ???
    (,) "WTF_IMPOSSIBLE"


neeiae : String -> Error
neeiae =
    -- You received an endpoint but Servers.get failed
    someGetReturnedNothing


notInServers : String -> Error
notInServers =
    -- ULTRA IMPORTANT Servers.get failed
    someGetReturnedNothing


someGetReturnedNothing : String -> Error
someGetReturnedNothing =
    -- ULTRA IMPORTANT Dict.get failed
    (,) "PAGE_FAULT_IN_NONPAGED_AREA"


porra : String -> Error
porra =
    -- Json was not as expected
    (,) "ERR_PORRA_RENATO"
