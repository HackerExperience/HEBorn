module Game.Storyline.Emails.Config exposing (..)


type alias Config msg =
    { username : String
    , onOpenBrowser : String -> msg
    }
