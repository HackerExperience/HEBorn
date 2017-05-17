module Apps.Browser.ModelTest exposing (all)

import Expect
import Test exposing (Test, describe, test)
import Fuzz exposing (int, tuple)
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
    [ fuzz int "can go to previous page" <|
        \seed ->
            let
                model =
                    Gen.model seed

                expectations =
                    model
                        |> getPreviousPages
                        |> List.head

                page =
                    model
                        |> gotoPreviousPage
                        |> getPage
            in
                Expect.equal expectations (Just page)
    , test "can't go to non-existing previous page" <|
        \() ->
            let
                model =
                    Gen.emptyModel

                model_ =
                    gotoPreviousPage model
            in
                Expect.equal model model_
    , fuzz (tuple ( int, int )) "browsing moves current page to past history" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                page1 =
                    Gen.page seed1

                page2 =
                    Gen.page seed2

                pages =
                    Gen.emptyModel
                        |> gotoPage page1
                        |> gotoPage page2
                        |> gotoPage page1
                        |> getPreviousPages

                expetations =
                    [ page2, page1, Gen.emptyPage ]
            in
                Expect.equal expetations pages
    ]



--------------------------------------------------------------------------------
-- Walk Forward History
--------------------------------------------------------------------------------


walkForwardHistoryTests : List Test
walkForwardHistoryTests =
    [ fuzz int "can go to next page" <|
        \seed ->
            let
                model =
                    Gen.model seed

                expectations =
                    model
                        |> getNextPages
                        |> List.head

                page =
                    model
                        |> gotoNextPage
                        |> getPage
            in
                Expect.equal expectations (Just page)
    , test "can't go to non-existing next page" <|
        \() ->
            let
                model =
                    Gen.emptyModel

                model_ =
                    gotoNextPage model
            in
                Expect.equal model model_
    , fuzz
        (tuple ( int, int ))
        "browsing back on history moves current page to future history"
      <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                page1 =
                    Gen.page seed1

                page2 =
                    Gen.page seed2

                pages =
                    Gen.emptyModel
                        |> gotoPage page1
                        |> gotoPage page2
                        |> gotoPage page1
                        |> gotoPreviousPage
                        |> gotoPreviousPage
                        |> gotoPreviousPage
                        |> getNextPages

                expetations =
                    [ page1, page2, page1 ]
            in
                Expect.equal expetations pages
    ]



--------------------------------------------------------------------------------
-- Browsing
--------------------------------------------------------------------------------


gotoPageTests : List Test
gotoPageTests =
    [ fuzz int "browsing the current page doesn't change the history" <|
        \seed ->
            let
                model =
                    Gen.model seed

                model_ =
                    gotoPage (getPage model) model
            in
                Expect.equal model model_
    , fuzz int "browsing erases future history" <|
        \seed ->
            let
                maybeEmptyHistory =
                    seed
                        |> Gen.model
                        |> gotoPage Gen.emptyPage
                        |> getNextPages
                        |> List.isEmpty
            in
                Expect.equal True maybeEmptyHistory
    ]
