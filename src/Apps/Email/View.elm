module Apps.Email.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Apps.Email.Messages exposing (Msg(..))
import Apps.Email.Models exposing (..)
import Apps.Email.Resources exposing (Classes(..), prefix)
import Apps.Email.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    let
        contactList =
            ul [ class [ Contacts ] ]
                [ li [ class [ Active ] ] [ text "Christian" ]
                , li [] [ text "Pedro" ]
                , li [] [ text "Charlotte" ]
                , li [] [ text "Mr Massaro" ]
                ]

        baloon dir msg =
            li [ class [ dir ] ] [ span [] [ text msg ] ]

        mainChat =
            div [ class [ MainChat ] ]
                [ ul []
                    [ baloon Sys "Today"
                    , baloon From "Wasap?"
                    , baloon To "Wasap!"
                    , baloon To "Just lost"
                    , baloon From "lost what?"
                    , baloon To "THE GAME"
                    , baloon From "'¬¬"
                    ]
                ]
    in
        div
            [ menuForDummy
            , class [ Super ]
            ]
            [ contactList
            , mainChat
            , menuView model
            ]
