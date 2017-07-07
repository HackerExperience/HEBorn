module Apps.Browser.Models exposing (..)

import Game.Web.Types as Web
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
    { app = initialBrowser
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
