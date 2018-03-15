module OS.WindowManager.Sidebar.Models exposing (..)


type alias Model =
    { isVisible : Bool
    }



-- about model


initialModel : Model
initialModel =
    { isVisible = False
    }


getVisibility : Model -> Bool
getVisibility =
    .isVisible


setVisibility : Bool -> Model -> Model
setVisibility isVisible model =
    { model | isVisible = isVisible }
