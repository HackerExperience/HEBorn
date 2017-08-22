module Game.Storyline.Emails.Models exposing (..)

import Time exposing (Time)
import Dict exposing (Dict)


type alias Model =
    Dict Email Chat


type alias Email =
    String


type alias Chat =
    ( Contact, Messages, Responses )


type alias Contact =
    { name : String
    , picture : String
    }


type Message
    = Sended PhraseID
    | Received PhraseID


type alias Messages =
    Dict Time Message


type alias Responses =
    List PhraseID


type alias PhraseID =
    String


initialModel : Model
initialModel =
    Dict.fromList
        [ ( "kress@hackerexperience.com"
          , ( (Contact "Christian" "meme.jpg")
            , Dict.fromList
                [ ( 1503355711568, Sended "Wasap?" )
                , ( 1503355740378, Received "Hello" )
                , ( 1503355855175, Sended "Just lost" )
                , ( 1503355909360, Received "lost what??" )
                , ( 1503355924759, Sended "THE GAME" )
                , ( 1503355933071, Received "'¬¬" )
                ]
            , [ "Tell me more...", "Reply" ]
            )
          )
        , ( "renato@hackerexperience.com"
          , ( Contact "Mr. Massaro" "familyfather.jpg"
            , Dict.empty
            , []
            )
          )
        , ( "mememori@hackerexperience.com"
          , ( Contact "Charlotte" "nicegirl.jpg"
            , Dict.empty
            , []
            )
          )
        ]
