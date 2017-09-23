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
import Apps.Browser.Pages.Models as Pages
import Game.Web.Types as Web


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


page : Fuzzer Pages.Model
page =
    fuzzer genPage


emptyPage : Fuzzer Pages.Model
emptyPage =
    fuzzer genEmptyPage


pageList : Fuzzer (List Pages.Model)
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


genPage : Generator Pages.Model
genPage =
    -- TODO: generate other site tpes
    let
        generate str =
            let
                site =
                    { url = str
                    , type_ = Web.NoWebserver
                    , meta =
                        { password = Nothing
                        , nip = ( "main", str )
                        }
                    }
            in
                Pages.initialModel site
    in
        map generate unique


genPageURL : Generator URL
genPageURL =
    stringRange 2 12


genEmptyPage : Generator Pages.Model
genEmptyPage =
    constant Pages.BlankModel


genPageList : Generator (List Pages.Model)
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
