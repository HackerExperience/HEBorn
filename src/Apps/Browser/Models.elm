module Apps.Browser.Models exposing (..)

import Html exposing (Html)
import Utils exposing (andThenWithDefault)
import Apps.Browser.Messages exposing (Msg)
import Apps.Browser.Menu.Models as Menu
import Apps.Browser.Pages exposing (PageURL, PageTitle, PageContent, getPageInitialContent)


type alias BrowserPage =
    { url : PageURL
    , content : PageContent
    , title : PageTitle
    }


type alias BrowserHistory =
    List BrowserPage


type alias Browser =
    { addressBar : PageURL
    , page : BrowserPage
    , previousPages : BrowserHistory
    , nextPages : BrowserHistory
    }


type alias Model =
    { app : Browser
    , menu : Menu.Model
    }


name : String
name =
    "Browser"


title : Model -> String
title ({ app } as model) =
    let
        pgTitle =
            app.page.title

        posfix =
            if (String.length pgTitle) > 12 then
                Just (": \"" ++ (String.left 10 pgTitle) ++ "[...]\"")
            else if (String.length pgTitle) > 0 then
                Just (": \"" ++ pgTitle ++ "\"")
            else
                Nothing
    in
        andThenWithDefault ((++) name) name posfix


icon : String
icon =
    "browser"


initialBrowser : Browser
initialBrowser =
    { addressBar = "about:blank"

    -- FIXME: update the content
    , page = { url = "about:blank", title = "Blank", content = [] }
    , previousPages = []
    , nextPages = []
    }


initialModel : Model
initialModel =
    { app = initialBrowser
    , menu = Menu.initialMenu
    }


getPage : Browser -> BrowserPage
getPage browser =
    browser.page


getPageURL : BrowserPage -> PageURL
getPageURL page =
    page.url


getPageTitle : BrowserPage -> PageTitle
getPageTitle page =
    page.title


getPageContent : BrowserPage -> PageContent
getPageContent page =
    page.content


getPreviousPages : Browser -> BrowserHistory
getPreviousPages browser =
    browser.previousPages


getNextPages : Browser -> BrowserHistory
getNextPages browser =
    browser.nextPages


gotoPage : BrowserPage -> Browser -> Browser
gotoPage page browser =
    if page /= getPage browser then
        let
            previousPages =
                browser.page :: (getPreviousPages browser)
        in
            { browser
                | addressBar = getPageURL page
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
                    , addressBar = (getPageURL page)
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
                    , addressBar = (getPageURL page)
                }

            Nothing ->
                browser


reorderHistory :
    (Browser -> BrowserHistory)
    -> (Browser -> BrowserHistory)
    -> Browser
    -> Maybe ( BrowserPage, BrowserHistory, BrowserHistory )
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


enterAddress : Browser -> Browser
enterAddress app =
    let
        url_ =
            app.addressBar
    in
        gotoPage { url = url_, content = getPageInitialContent url_, title = "" } app
