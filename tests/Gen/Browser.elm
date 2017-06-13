module Gen.Browser exposing (..)

import Fuzz exposing (Fuzzer)
import Gen.Utils exposing (fuzzer, unique, stringRange, listRange)
import Random.Pcg
    exposing
        ( Generator
        , constant
        , int
        , list
        , choices
        , map3
        , andThen
        )
import Apps.Browser.Models exposing (..)
import Apps.Browser.Pages exposing (PageURL, PageTitle, PageContent)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


pageURL : Fuzzer PageURL
pageURL =
    fuzzer genPageURL


title : Fuzzer PageTitle
title =
    fuzzer genTitle


content : Fuzzer PageContent
content =
    fuzzer genContent


page : Fuzzer BrowserPage
page =
    fuzzer genPage


emptyPage : Fuzzer BrowserPage
emptyPage =
    fuzzer genEmptyPage


pageList : Fuzzer (List BrowserPage)
pageList =
    fuzzer genPageList


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


genPageURL : Generator PageURL
genPageURL =
    -- TODO: add url generator
    unique


genTitle : Generator PageTitle
genTitle =
    -- TODO: add title generator
    unique


genContent : Generator PageContent
genContent =
    -- TODO: add random html content generator
    constant []


genPage : Generator BrowserPage
genPage =
    map3 BrowserPage
        genPageURL
        genContent
        genTitle


genEmptyPage : Generator BrowserPage
genEmptyPage =
    constant (BrowserPage "about:blank" [] "Blank")


genPageList : Generator (List BrowserPage)
genPageList =
    andThen ((flip list) genPage) (int 2 10)


genEmptyHistory : Generator BrowserHistory
genEmptyHistory =
    constant []


genNonEmptyHistory : Generator BrowserHistory
genNonEmptyHistory =
    genPageList


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
            \past future current ->
                Browser
                    (getPageTitle current)
                    current
                    past
                    future
    in
        map3 mapper
            genNonEmptyHistory
            genNonEmptyHistory
            genPage


genBrowser : Generator Browser
genBrowser =
    choices [ genEmptyBrowser, genNonEmptyBrowser ]


genModel : Generator Browser
genModel =
    genNonEmptyBrowser


genEmptyModel : Generator Browser
genEmptyModel =
    genEmptyBrowser
