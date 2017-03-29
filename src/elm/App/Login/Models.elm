module App.Login.Models exposing (..)


type alias Model =
    { errors : Maybe String
    }


initialModel : Model
initialModel =
    { errors = Nothing
    }
