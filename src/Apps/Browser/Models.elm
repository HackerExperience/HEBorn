module Apps.Browser.Models exposing (..)

import Dict exposing (Dict)
import Utils.List as List
import Apps.Browser.Menu.Models as Menu
import Apps.Browser.Pages.Models as Pages


type alias BrowserHistory =
    List Pages.Model


type alias Browser =
    { addressBar : String
    , page : Pages.Model
    , previousPages : BrowserHistory
    , nextPages : BrowserHistory
    }


type alias Tabs =
    Dict Int Browser


type alias Model =
    { tabs : Tabs
    , nowTab : Int
    , leftTabs : List Int
    , rightTabs : List Int
    , lastTab : Int
    , menu : Menu.Model
    }


name : String
name =
    "Browser"


title : Model -> String
title model =
    let
        app =
            getApp model

        pgTitle =
            Pages.getTitle (getPage app)

        posfix =
            if (String.length pgTitle) > 12 then
                Just (": \"" ++ (String.left 10 pgTitle) ++ "[...]\"")
            else if (String.length pgTitle) > 0 then
                Just (": \"" ++ pgTitle ++ "\"")
            else
                Nothing
    in
        posfix
            |> Maybe.map ((++) name)
            |> Maybe.withDefault name


icon : String
icon =
    "browser"


initialBrowser : Browser
initialBrowser =
    { addressBar = "about:blank"
    , page = Pages.BlankModel
    , previousPages = []
    , nextPages = []
    }


initialModel : Model
initialModel =
    { tabs =
        Dict.fromList
            [ ( 0, initialBrowser ) ]
    , nowTab = 0
    , lastTab = 0
    , leftTabs = []
    , rightTabs = []
    , menu = Menu.initialMenu
    }


getPage : Browser -> Pages.Model
getPage browser =
    browser.page


getPreviousPages : Browser -> BrowserHistory
getPreviousPages browser =
    browser.previousPages


getNextPages : Browser -> BrowserHistory
getNextPages browser =
    browser.nextPages


gotoPage : Pages.Model -> Browser -> Browser
gotoPage page browser =
    if page /= getPage browser then
        let
            previousPages =
                browser.page :: (getPreviousPages browser)
        in
            { browser
                | addressBar = Pages.getUrl page
                , page = page
                , previousPages = previousPages
                , nextPages = []
            }
    else
        browser


gotoPreviousPage : Browser -> Browser
gotoPreviousPage browser =
    let
        maybeReorderedHistory =
            reorderHistory getPreviousPages getNextPages browser
    in
        case maybeReorderedHistory of
            Just ( page, prev, next ) ->
                { browser
                    | page = page
                    , previousPages = prev
                    , nextPages = next
                    , addressBar = (Pages.getUrl page)
                }

            Nothing ->
                browser


gotoNextPage : Browser -> Browser
gotoNextPage browser =
    let
        maybeReorderedHistory =
            reorderHistory getNextPages getPreviousPages browser
    in
        case maybeReorderedHistory of
            Just ( page, next, prev ) ->
                { browser
                    | page = page
                    , previousPages = prev
                    , nextPages = next
                    , addressBar = (Pages.getUrl page)
                }

            Nothing ->
                browser


reorderHistory :
    (Browser -> BrowserHistory)
    -> (Browser -> BrowserHistory)
    -> Browser
    -> Maybe ( Pages.Model, BrowserHistory, BrowserHistory )
reorderHistory getFromList getToList browser =
    let
        from =
            getFromList browser

        to =
            getToList browser

        oldPage =
            getPage browser
    in
        case List.head from of
            Just newPage ->
                let
                    from_ =
                        from
                            |> List.tail
                            |> Maybe.withDefault ([])

                    to_ =
                        oldPage :: to
                in
                    Just ( newPage, from_, to_ )

            Nothing ->
                Nothing


getTab : Int -> Tabs -> Browser
getTab id src =
    Dict.get id src
        |> Maybe.withDefault
            initialBrowser


setTab : Int -> Browser -> Tabs -> Tabs
setTab id value src =
    Dict.insert id value src


getApp : Model -> Browser
getApp model =
    getTab model.nowTab model.tabs


setApp : Browser -> Model -> Model
setApp app model =
    let
        newTabs =
            setTab model.nowTab app model.tabs
    in
        { model | tabs = newTabs }


goTab : Int -> Model -> Model
goTab nTab model =
    if nTab == model.nowTab then
        model
    else if List.member nTab model.rightTabs then
        let
            ( wL, newRight ) =
                List.splitOut
                    (model.rightTabs
                        |> List.memberIndex nTab
                        |> Maybe.withDefault 0
                    )
                    model.rightTabs

            newLeft =
                model.leftTabs ++ [ model.nowTab ] ++ wL
        in
            { model
                | leftTabs = newLeft
                , rightTabs = newRight
                , nowTab = nTab
            }
    else
        let
            ( newLeft, wR ) =
                List.splitOut
                    (model.leftTabs
                        |> List.memberIndex nTab
                        |> Maybe.withDefault 0
                    )
                    model.leftTabs

            newRight =
                wR ++ [ model.nowTab ] ++ model.rightTabs
        in
            { model
                | leftTabs = newLeft
                , rightTabs = newRight
                , nowTab = nTab
            }


addTab : Model -> Model
addTab model =
    let
        newN =
            model.lastTab + 1

        tabs =
            Dict.insert newN initialBrowser model.tabs

        rightTabs =
            newN :: model.rightTabs
    in
        { model | tabs = tabs, lastTab = newN, rightTabs = rightTabs }


deleteTab : Int -> Model -> Model
deleteTab nTab model =
    if nTab == model.nowTab then
        case model.rightTabs of
            [] ->
                case List.reverse model.leftTabs of
                    [] ->
                        initialModel

                    [ unique ] ->
                        { model | nowTab = unique, leftTabs = [] }

                    head :: tail ->
                        { model | nowTab = head, leftTabs = List.reverse tail }

            [ unique ] ->
                { model | nowTab = unique, rightTabs = [] }

            head :: tail ->
                { model | nowTab = head, rightTabs = tail }
    else if List.member nTab model.leftTabs then
        let
            ( wL, wR ) =
                List.splitOut
                    (model.leftTabs
                        |> List.memberIndex nTab
                        |> Maybe.withDefault 0
                    )
                    model.leftTabs
        in
            { model | leftTabs = wL ++ wR }
    else
        let
            ( wL, wR ) =
                List.splitOut
                    (model.rightTabs
                        |> List.memberIndex nTab
                        |> Maybe.withDefault 0
                    )
                    model.rightTabs
        in
            { model | rightTabs = wL ++ wR }
