module Apps.ConnManager.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Entries.FilterHeader exposing (filterHeader)
import Apps.ConnManager.Messages exposing (Msg(..))
import Apps.ConnManager.Models exposing (..)
import Apps.ConnManager.Style exposing (Classes(..), prefix)
import Apps.ConnManager.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


viewEntry : String -> Html Msg
viewEntry src =
    div [] []


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    let
        filterHeaderLayout =
            verticalList
                [ filterHeader
                    [ ( class [ IcoUp ], DummyNoOp, False )
                    , ( class [ IcoDown ], DummyNoOp, False )
                    ]
                    []
                    app.filterText
                    "Search..."
                    UpdateTextFilter
                ]

        mainEntries =
            verticalList
                []
    in
        verticalSticked
            (Just [ filterHeaderLayout ])
            [ mainEntries
            , menuView model
            ]
            Nothing
