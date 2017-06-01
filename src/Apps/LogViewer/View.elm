module Apps.LogViewer.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (asPairs)
import Css.Common exposing (elasticClass)
import Game.Shared exposing (..)
import Game.Models exposing (GameModel)
import Game.Servers.Filesystem.Models exposing (FilePath)
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Menu.Models exposing (Menu(..))
import Apps.LogViewer.Style exposing (Classes(..))
import Date exposing (Date, fromTime)
import Date.Format as DateFormat exposing (format)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "logvw"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style



-- VIEW WRAPPER


renderAddr : IP -> List (Html Msg)
renderAddr addr =
    if (addr == localhost) then
        [ span [ class [ IcoHome, ColorLocal ] ] []
        , text " "
        , span [ class [ IdLocal, ColorLocal ] ] [ text localhost ]
        ]
    else
        [ span [ class [ IcoCrosshair, ColorRemote ] ] []
        , text " "
        , span [ class [ IdMe, ColorRemote ] ] [ text addr ]
        ]


renderUser : ServerUser -> List (Html Msg)
renderUser user =
    if (user == root) then
        [ span [ class [ IcoUser, ColorRoot ] ] []
        , text " "
        , span [ class [ IdRoot, ColorRoot ] ] [ text user ]
        ]
    else
        [ span [ class [ IcoUser ] ] []
        , text " "
        , span [] [ text user ]
        ]


renderButton : LogID -> Classes -> List (Html Msg)
renderButton logID btn =
    [ text " "
    , span
        ([ class [ btn ] ]
            ++ (case btn of
                    BtnEdit ->
                        [ onClick (EnterEditing logID) ]

                    _ ->
                        []
               )
        )
        []
    ]


renderButtons : LogID -> List Classes -> List (Html Msg)
renderButtons logID btns =
    btns
        |> List.map (renderButton logID)
        |> List.concat
        |> List.tail
        |> Maybe.withDefault []


renderMsg : LogEventMsg -> Html Msg
renderMsg msg =
    div [ class [ EData ] ]
        (case msg of
            LogIn addr user ->
                (renderAddr addr
                    ++ [ span [] [ text " logged in as " ] ]
                    ++ renderUser user
                )

            Connection actor src dest ->
                (renderAddr actor
                    ++ [ span [] [ text " bounced connection from " ]
                       , span [ class [ IcoCrosshair, ColorRemote ] ] []
                       , text " "
                       , span [ class [ IdMe, ColorRemote ] ] [ text src ]
                       , span [] [ text " to " ]
                       , span [ class [ IcoDangerous, ColorDangerous ] ] []
                       , text " "
                       , span [ class [ IdOther, ColorDangerous ] ] [ text dest ]
                       ]
                )

            ExternalAcess whom aswho ->
                (renderUser whom
                    ++ [ span [] [ text " logged in as " ] ]
                    ++ renderUser aswho
                )

            _ ->
                []
        )


renderMiniMsg : LogEventMsg -> Html Msg
renderMiniMsg msg =
    (case msg of
        Connection actor src dest ->
            div [ class [ EData ] ]
                (renderAddr actor
                    ++ [ span [] [ text " bounced connection from " ]
                       , span [ class [ IcoCrosshair, ColorRemote ] ] []
                       , text " "
                       , span [ class [ IdMe, ColorRemote ] ] [ text src ]
                       , span [] [ text " to ..." ]
                       ]
                )

        _ ->
            renderMsg msg
    )


renderEditing : String -> Html Msg
renderEditing src =
    input [ class [ EData, BoxifyMe ], value src ] []


renderTopActions : LogViewerEntry -> Html Msg
renderTopActions entry =
    div [ class [ ETActMini ] ]
        (renderButtons entry.srcID
            (case entry.status of
                Normal expanded ->
                    (if expanded then
                        [ BtnUser, BtnEdit ]
                     else
                        [ BtnEdit ]
                    )

                Cryptographed True ->
                    [ BtnLock ]

                _ ->
                    []
            )
        )


renderBottomActions : LogViewerEntry -> Html Msg
renderBottomActions entry =
    div [ class [ EAct ] ]
        (renderButtons
            entry.srcID
            (case entry.status of
                Normal True ->
                    [ BtnLock, BtnView, BtnEdit, BtnDelete ]

                Cryptographed True ->
                    [ BtnView, BtnUnlock ]

                Editing ->
                    [ BtnApply, BtnCancel ]

                _ ->
                    []
            )
        )


renderEntryToggler : LogID -> Html Msg
renderEntryToggler logID =
    div
        [ class [ CasedBtnExpand, EToggler ]
        , onClick (ToogleLog logID)
        ]
        []


renderData : LogViewerEntry -> Html Msg
renderData entry =
    if (entry.status == Editing) then
        renderEditing entry.src
    else if (isEntryExpanded entry) then
        renderMsg entry.message
    else
        renderMiniMsg entry.message


renderBottom : LogViewerEntry -> Html Msg
renderBottom entry =
    if (entry.status == Editing) then
        div
            [ class [ EBottom ] ]
            [ renderBottomActions entry ]
    else if (isEntryExpanded entry) then
        div
            [ class [ EBottom, EntryExpanded ] ]
            [ renderBottomActions entry
            , renderEntryToggler entry.srcID
            ]
    else
        div
            [ class [ EBottom ] ]
            [ div [ class [ EAct ] ] []
            , renderEntryToggler entry.srcID
            ]


renderEntry : LogViewerEntry -> Html Msg
renderEntry entry =
    div
        [ class
            (if (isEntryExpanded entry) then
                [ Entry, EntryExpanded ]
             else
                [ Entry ]
            )
        ]
        ([ div [ class [ ETop ] ]
            [ div [] [ text (DateFormat.format "%d/%m/%Y - %H:%M:%S" entry.timestamp) ]
            , div [ elasticClass ] []
            , renderTopActions entry
            ]
         , renderData entry
         , renderBottom entry
         ]
        )


renderEntryList : List LogViewerEntry -> List (Html Msg)
renderEntryList =
    List.map renderEntry



-- END OF THAT


view : GameModel -> Model -> Html Msg
view game model =
    div []
        ([ div [ class [ HeaderBar ] ]
            [ div [ class [ ETAct ] ]
                [ span [ class [ BtnUser ] ] []
                , text " "
                , span [ class [ BtnEdit ] ] []
                , text " "
                , span [ class [ BtnView ] ] []
                ]
            , div [ class [ ETFilter ] ]
                [ div [ class [ BtnFilter ] ] []
                , div [ class [ ETFBar ] ]
                    [ input
                        [ placeholder "Search..."
                        , onInput UpdateFilter
                        ]
                        []
                    ]
                ]
            ]
         ]
            ++ (model.app.entries
                    |> Dict.filter
                        (\k v -> String.contains model.app.filtering v.src)
                    |> Dict.values
                    |> renderEntryList
               )
        )
