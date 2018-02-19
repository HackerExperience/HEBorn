module Game.Storyline.Emails.Contents.Config exposing (..)


type alias Config msg =
    { username : String
    , onOpenBrowser : String -> msg
    }
