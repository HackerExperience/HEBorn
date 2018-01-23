module Game.Storyline.Emails.Contents.Config exposing (..)


type alias Config msg =
    { username : String
    , batchMsg : List msg -> msg
    }
