module Gen.Browser exposing (..)

import Fuzz exposing (Fuzzer)
import Gen.Utils exposing (fuzzer, unique, stringRange, listRange)
import Random.Pcg
    exposing
        ( Generator
        , constant
        , int
        , list
        , pair
        , choices
        , map
        , map2
        , andThen
        )
import Random.Pcg.Extra exposing (andMap)
import Apps.Browser.Models exposing (..)
import Game.Web.Types as Web


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


page : Fuzzer Page
page =
    fuzzer genPage


emptyPage : Fuzzer Page
emptyPage =
    fuzzer genEmptyPage


pageList : Fuzzer (List Page)
pageList =
    fuzzer genPageList


pageURL : Fuzzer URL
pageURL =
    fuzzer genPageURL


emptyHistory : Fuzzer BrowserHistory
emptyHistory =
    fuzzer genEmptyHistory


nonEmptyHistory : Fuzzer BrowserHistory
nonEmptyHistory =
    fuzzer genNonEmptyHistory


history : Fuzzer BrowserHistory
history =
    fuzzer genHistory


emptyTab : Fuzzer Tab
emptyTab =
    fuzzer genEmptyTab


nonEmptyTab : Fuzzer Tab
nonEmptyTab =
    fuzzer genNonEmptyTab


tab : Fuzzer Tab
tab =
    fuzzer genTab


model : Fuzzer Tab
model =
    fuzzer genModel


emptyModel : Fuzzer Tab
emptyModel =
    fuzzer genEmptyModel



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genPage : Generator Page
genPage =
    -- TODO: generate other site tpes
    let
        generate str =
            let
                site =
                    { url = str
                    , type_ = Web.Webserver { custom = "" }
                    , meta =
                        { password = Nothing
                        , nip = ( "main", str )
                        , publicFiles = []
                        }
                    }
            in
                initialPage site
    in
        map generate unique


genPageURL : Generator URL
genPageURL =
    stringRange 2 12


genEmptyPage : Generator Page
genEmptyPage =
    constant BlankModel


genPageList : Generator (List Page)
genPageList =
    andThen ((flip list) genPage) (int 2 10)


genEmptyHistory : Generator BrowserHistory
genEmptyHistory =
    constant []


genNonEmptyHistory : Generator BrowserHistory
genNonEmptyHistory =
    andThen ((flip list) (pair genPageURL genPage)) (int 2 10)


genHistory : Generator BrowserHistory
genHistory =
    choices [ genEmptyHistory, genNonEmptyHistory ]


genEmptyTab : Generator Tab
genEmptyTab =
    constant initTab


genNonEmptyTab : Generator Tab
genNonEmptyTab =
    let
        mapper =
            \past future url current ->
                { addressBar = url
                , lastURL = url
                , page = current
                , previousPages = past
                , nextPages = future
                , modal = Nothing
                }
    in
        genNonEmptyHistory
            |> map mapper
            |> andMap genNonEmptyHistory
            |> andMap genPageURL
            |> andMap genPage


genTab : Generator Tab
genTab =
    choices [ genEmptyTab, genNonEmptyTab ]


genModel : Generator Tab
genModel =
    genNonEmptyTab


genEmptyModel : Generator Tab
genEmptyModel =
    genEmptyTab
