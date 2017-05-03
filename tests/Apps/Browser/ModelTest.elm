module Apps.Browser.ModelTest exposing (all)

import Expect
import Maybe exposing (andThen)
import Test exposing (Test, describe, test)
import Fuzz exposing (int, tuple)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Gen.Browser as Gen
import Apps.Browser.Models exposing (..)


all : Test
all =
    describe "browser"
        [ tabOperations
        , browseOperations
        ]


tabOperations : Test
tabOperations =
    describe "tab operations"
        [ describe "open tabs"
            openTabTests
        , describe "close tabs"
            closeTabTests
        , describe "focus tabs"
            tabFocusTests
        ]


browseOperations : Test
browseOperations =
    describe "browsing operations"
        [ describe "goto page"
            gotoPageTests
        , describe "moving history backward"
            walkBackwardHistoryTests
        , describe "moving history forward"
            walkForwardHistoryTests
        ]



--------------------------------------------------------------------------------
-- Open Tab Tests
--------------------------------------------------------------------------------


openTabTests : List Test
openTabTests =
    [ fuzz int "opening a tab changes the focus to it" <|
        \seed ->
            let
                page =
                    Gen.page seed
            in
                Gen.emptyModel
                    |> openTab page
                    |> getTab
                    |> getPage
                    |> Expect.equal page
    , fuzz int "opening a tab on background won't change the focus" <|
        \seed ->
            Gen.emptyModel
                |> openTabBackground (Gen.page seed)
                |> getTab
                |> getPage
                |> Expect.equal Gen.emptyPage
    ]



--------------------------------------------------------------------------------
-- Close Tab Tests
--------------------------------------------------------------------------------


closeTabTests : List Test
closeTabTests =
    [ test "closing every tab returns a browser with the initial tab" <|
        \() ->
            Gen.emptyModel
                |> closeTab 0
                |> Expect.equal Gen.emptyModel
    , fuzz
        int
        "closing the current tab changes the focus to the previous tab"
      <|
        \seed ->
            Gen.emptyModel
                |> openTab (Gen.page seed)
                |> openTab Gen.emptyPage
                |> openTab (Gen.page seed)
                |> closeTab 3
                |> getTab
                |> getPage
                |> Expect.equal Gen.emptyPage
    ]



--------------------------------------------------------------------------------
-- Focus Tab Tests
--------------------------------------------------------------------------------


tabFocusTests : List Test
tabFocusTests =
    [ fuzz int "changing focus to previous page" <|
        \seed ->
            Gen.emptyModel
                |> openTab (Gen.page seed)
                |> focusTab 0
                |> getTab
                |> getPage
                |> Expect.equal Gen.emptyPage
    , fuzz int "changing focus to next page" <|
        \seed ->
            let
                page =
                    Gen.page seed
            in
                Gen.emptyModel
                    |> openTab page
                    |> focusTab 0
                    |> focusTab 1
                    |> getTab
                    |> getPage
                    |> Expect.equal page
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

                page =
                    model
                        |> getTab
                        |> getPage

                model_ =
                    gotoPage page model
            in
                Expect.equal model model_
    , fuzz int "browsing erases future history" <|
        \seed ->
            let
                maybeEmptyHistory =
                    seed
                        |> Gen.model
                        |> gotoPage Gen.emptyPage
                        |> getTab
                        |> getNextPages
                        |> List.isEmpty
            in
                Expect.equal True maybeEmptyHistory
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
                        |> getTab
                        |> getPreviousPages
                        |> List.head

                page =
                    model
                        |> gotoPreviousPage
                        |> getTab
                        |> getPage
            in
                Expect.equal expectations (Just page)
    , test
        "can't go to non-existing previous page"
      <|
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
                        |> getTab
                        |> getPreviousPages

                expectations =
                    [ page2, page1, Gen.emptyPage ]
            in
                Expect.equal expectations pages
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
                        |> getTab
                        |> getNextPages
                        |> List.head

                page =
                    model
                        |> gotoNextPage
                        |> getTab
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
                        |> getTab
                        |> getNextPages

                expetations =
                    [ page1, page2, page1 ]
            in
                Expect.equal expetations pages
    ]
