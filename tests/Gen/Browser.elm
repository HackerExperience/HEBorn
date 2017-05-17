module Gen.Browser exposing (..)

import Apps.Browser.Messages exposing (Msg(..))
import Gen.Utils exposing (..)
import Apps.Browser.Models exposing (..)


url : Int -> PageURL
url seedInt =
    fuzz1 seedInt urlSeed


urlSeed : Seed -> ( PageURL, Seed )
urlSeed seed =
    smallStringSeed seed


page : Int -> BrowserPage
page seedInt =
    fuzz1 seedInt pageSeed


pageSeed : Seed -> ( BrowserPage, Seed )
pageSeed seed =
    let
        ( url, seed_ ) =
            urlSeed seed

        -- FIXME: update the content
        page =
            { url = url, title = "", content = "" }
    in
        ( page, seed_ )


emptyPage : BrowserPage
emptyPage =
    -- FIXME: update the content
    { url = "about:blank", title = "", content = "" }


history : Int -> BrowserHistory
history seedInt =
    fuzz1 seedInt historySeed


historySeed : Seed -> ( BrowserHistory, Seed )
historySeed seed =
    let
        ( size, seed_ ) =
            intRangeSeed 1 10 seed

        list =
            List.range 0 size

        reducer =
            \_ ( pages, seed ) ->
                let
                    ( page, seed_ ) =
                        pageSeed seed
                in
                    ( page :: pages, seed_ )
    in
        List.foldl reducer ( [], seed_ ) list


browser : Int -> Browser
browser seedInt =
    fuzz1 seedInt browserSeed


browserSeed : Seed -> ( Browser, Seed )
browserSeed seed =
    let
        ( prevHistory, seed1 ) =
            historySeed seed

        ( nextHistory, seed2 ) =
            historySeed seed1

        ( currentPage, seed_ ) =
            pageSeed seed2

        browser =
            browserParams prevHistory nextHistory currentPage
    in
        ( browser, seed_ )


browserParams : BrowserHistory -> BrowserHistory -> BrowserPage -> Browser
browserParams prevHistory nextHistory page =
    { addressBar = getPageURL page
    , page = page
    , previousPages = prevHistory
    , nextPages = nextHistory
    }


emptyBrowser : Browser
emptyBrowser =
    initialBrowser


model : Int -> Browser
model seedInt =
    fuzz1 seedInt modelSeed


modelSeed : Seed -> ( Browser, Seed )
modelSeed seed =
    browserSeed seed


emptyModel : Browser
emptyModel =
    emptyBrowser
