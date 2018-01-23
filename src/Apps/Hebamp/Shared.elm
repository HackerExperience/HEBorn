module Apps.Hebamp.Shared exposing (..)


type alias AudioData =
    { mediaUrl : String
    , mediaType : String
    , label : String
    , duration : Float
    }


type Params
    = OpenPlaylist (List AudioData)
