module App.Core.Models exposing (..)

type alias Model =
    { token : Maybe String
    }

initialModel : Model
initialModel =
    { token = Nothing
    }
