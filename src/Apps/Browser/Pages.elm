module Apps.Browser.Pages exposing (..)

import Html exposing (Html)
import Apps.Browser.Messages exposing (Msg)


type alias PageURL =
    String


type alias PageTitle =
    String


type PageContent
    = PgBlank
    | PgWelcome String
    | PgCustom (List (Html Msg))
    | PgError404


urlParse : PageURL -> PageContent
urlParse url =
    case url of
        "about:blank" ->
            PgBlank

        "localhost" ->
            PgWelcome "localhost"

        _ ->
            PgError404
