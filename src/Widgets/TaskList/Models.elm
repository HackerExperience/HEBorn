module Widgets.TaskList.Models exposing (..)


type alias Model =
    { entries : List ( Bool, String )
    , title : String
    }


initialModel : Model
initialModel =
    Model
        [ ( True, "Pull back the lid of your Cup noodles" )
        , ( True, "Add boiling water" )
        , ( False, "Cover the lid" )
        , ( False, "Wait three minutes" )
        , ( False, "Remove lid completely" )
        , ( False, "Enjoy!" )
        ]
        "How To Noodles"


getTitle : Model -> String
getTitle { title } =
    (++) "Tasks: " <|
        if String.isEmpty title then
            "Unnamed"
        else
            title
