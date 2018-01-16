module Apps.Popup.Data exposing (Data)

import Html exposing (Html)


type alias Data =
    { title : String
    , content : Html Never
    }
