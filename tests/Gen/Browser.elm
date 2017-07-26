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


emptyBrowser : Fuzzer Browser
emptyBrowser =
    fuzzer genEmptyBrowser


nonEmptyBrowser : Fuzzer Browser
nonEmptyBrowser =
    fuzzer genNonEmptyBrowser


browser : Fuzzer Browser
browser =
    fuzzer genBrowser


model : Fuzzer Browser
model =
    fuzzer genModel


emptyModel : Fuzzer Browser
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
                    { type_ = Web.Default
                    , url = str
                    , meta =
                        str
                            |> Web.DefaultMetadata
                            |> Web.DefaultMeta
                            |> Just
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
    constant <|
        Pages.initialModel
            { type_ = Web.Blank
            , url = "about:blank"
            , meta = Nothing
            }


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


genEmptyBrowser : Generator Browser
genEmptyBrowser =
    constant initialBrowser


genNonEmptyBrowser : Generator Browser
genNonEmptyBrowser =
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


genBrowser : Generator Browser
genBrowser =
    choices [ genEmptyBrowser, genNonEmptyBrowser ]


genModel : Generator Browser
genModel =
    genNonEmptyBrowser


genEmptyModel : Generator Browser
genEmptyModel =
    genEmptyBrowser
