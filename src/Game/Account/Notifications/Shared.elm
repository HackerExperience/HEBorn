module Game.Account.Notifications.Shared exposing (..)


type Content
    = Generic Title Message
    | NewEmail PersonId


type alias Title =
    String


type alias Message =
    String


type alias PersonId =
    String


render : Content -> ( String, String )
render content =
    case content of
        Generic title body ->
            ( title, body )

        NewEmail from ->
            ( "New email from: " ++ from
            , "Check on Thunderpigeon"
            )



-- it might make sense to return html instead


renderToast : Content -> ( String, String )
renderToast content =
    case content of
        Generic title body ->
            ( title, body )

        NewEmail from ->
            ( "New email from: " ++ from
            , "Click to open Thunderpigeon"
            )
