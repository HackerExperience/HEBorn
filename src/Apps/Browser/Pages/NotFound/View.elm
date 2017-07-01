module Apps.Browser.Pages.NotFound.View exposing (view)

import Html exposing (Html, div, text)


view : Html Never
view =
    div [] [ text "404 (page not found)" ]
