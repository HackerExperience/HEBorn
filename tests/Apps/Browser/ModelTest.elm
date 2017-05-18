module Apps.Browser.ModelTest exposing (all)

import Expect
import Test exposing (Test, describe, test)
import Fuzz exposing (int, tuple, tuple3, tuple4)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Gen.Browser as Gen
import Apps.Browser.Models exposing (..)


all : Test
all =
    describe "browser"
        [ historyOperations
        , browseOperations
        ]


historyOperations : Test
historyOperations =
    describe "history operations"
        [ describe "moving history backward"
            walkBackwardHistoryTests
        , describe "moving history forward"
            walkForwardHistoryTests
        ]


browseOperations : Test
browseOperations =
    describe "browsing operations"
        [ describe "goto page"
            gotoPageTests
        ]



--------------------------------------------------------------------------------
-- Walk Backward History
--------------------------------------------------------------------------------


walkBackwardHistoryTests : List Test
walkBackwardHistoryTests =
    [ fuzz Gen.model "can go to previous page" <|
        \model ->
            let
                expectations =
                    model
                        |> getPreviousPages
                        |> List.head
            in
                model
                    |> gotoPreviousPage
                    |> getPage
                    |> Just
                    |> Expect.equal expectations
    , fuzz Gen.emptyModel "can't go to non-existing previous page" <|
        \model ->
            model
                |> gotoPreviousPage
                |> Expect.equal model
    , fuzz
        (tuple4 ( Gen.emptyModel, Gen.page, Gen.page, Gen.emptyPage ))
        "browsing moves current page to past history"
      <|
        \( model, page1, page2, emptyPage ) ->
            model
                |> gotoPage page1
                |> gotoPage page2
                |> gotoPage page1
                |> getPreviousPages
                |> Expect.equal [ page2, page1, emptyPage ]
    ]



--------------------------------------------------------------------------------
-- Walk Forward History
--------------------------------------------------------------------------------


walkForwardHistoryTests : List Test
walkForwardHistoryTests =
    [ fuzz Gen.model "can go to next page" <|
        \model ->
            let
                expectations =
                    model
                        |> getNextPages
                        |> List.head
            in
                model
                    |> gotoNextPage
                    |> getPage
                    |> Just
                    |> Expect.equal expectations
    , fuzz Gen.emptyModel "can't go to non-existing next page" <|
        \model ->
            model
                |> gotoNextPage
                |> Expect.equal model
    , fuzz
        (tuple3 ( Gen.emptyModel, Gen.page, Gen.page ))
        "browsing back on history moves current page to future history"
      <|
        \( model, page1, page2 ) ->
            model
                |> gotoPage page1
                |> gotoPage page2
                |> gotoPage page1
                |> gotoPreviousPage
                |> gotoPreviousPage
                |> gotoPreviousPage
                |> getNextPages
                |> Expect.equal [ page1, page2, page1 ]
    ]



--------------------------------------------------------------------------------
-- Browsing
--------------------------------------------------------------------------------


gotoPageTests : List Test
gotoPageTests =
    [ fuzz Gen.model "browsing the current page doesn't change the history" <|
        \model ->
            model
                |> gotoPage (getPage model)
                |> Expect.equal model
    , fuzz
        (tuple ( Gen.model, Gen.emptyPage ))
        "browsing erases future history"
      <|
        \( model, page ) ->
            model
                |> gotoPage page
                |> getNextPages
                |> List.isEmpty
                |> Expect.equal True
    ]
