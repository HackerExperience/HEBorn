module Apps.Browser.Widgets.HackingToolkit.Model
    exposing
        ( Model
        , Password
        , Address
        , setPassword
        )

import Game.Meta.Types.Network exposing (NIP)


type alias Model =
    { password : Maybe String
    , target : NIP
    }


type alias Password =
    Maybe String


type alias Address =
    String


setPassword : String -> Model -> Model
setPassword password model =
    let
        newPassword =
            if password == "" then
                Nothing
            else
                Just password
    in
        { model | password = newPassword }
