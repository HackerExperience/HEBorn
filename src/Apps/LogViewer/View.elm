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
import Apps.Instances.Models as Instance exposing (InstanceID)
import Apps.Context as Context
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Models exposing (LogID, Model, LogViewer, getState, LogViewerEntry, LogEventMsg(..), getLogViewerInstance)
import Apps.LogViewer.Context.Models exposing (Context(..))
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


renderButtons : List Classes -> List (Html Msg)
renderButtons btns =
    btns
        |> List.map (\d -> [ text " ", span [ class [ d ] ] [] ])
        |> List.concat
        |> List.tail
        |> Maybe.withDefault []


renderMsg : LogEventMsg -> Html Msg
renderMsg msg =
    (case msg of
        LogIn addr user ->
            div [ class [ EData ] ]
                (renderAddr addr
                    ++ [ span [] [ text " logged in as " ] ]
                    ++ renderUser user
                )

        Connection actor src dest ->
            div [ class [ EData ] ]
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
            div [ class [ EData, BoxifyMe ] ]
                (renderUser whom
                    ++ [ span [] [ text " logged in as " ] ]
                    ++ renderUser aswho
                )

        _ ->
            div [ class [ EData ] ] []
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


renderTopActions : LogEventMsg -> Html Msg
renderTopActions msg =
    div [ class [ ETActMini ] ]
        (case msg of
            LogIn addr user ->
                renderButtons [ BtnEdit ]

            Connection actor src dest ->
                renderButtons [ BtnUser, BtnEdit ]

            ExternalAcess whom aswho ->
                []

            _ ->
                renderButtons [ BtnLock ]
        )


renderBottomActions : LogEventMsg -> Html Msg
renderBottomActions msg =
    div [ class [ EAct ] ]
        (case msg of
            LogIn addr user ->
                []

            Connection actor src dest ->
                renderButtons [ IcoUser, BtnView, BtnEdit, BtnDelete ]

            ExternalAcess whom aswho ->
                renderButtons [ BtnApply, BtnCancel ]

            _ ->
                []
        )


renderEntryToggler : InstanceID -> LogID -> Html Msg
renderEntryToggler instID logID =
    div
        [ class [ CasedBtnExpand, EToggler ]
        , onClick (ToogleLog instID logID)
        ]
        []


renderEntry : InstanceID -> LogViewerEntry -> Html Msg
renderEntry instanceID entry =
    div
        [ class
            (if entry.expanded then
                [ Entry ]
             else
                [ Entry, EntryExpanded ]
            )
        ]
        ([ div [ class [ ETop ] ]
            [ div [] [ text (DateFormat.format "%d/%m/%Y - %H:%M:%S" entry.timestamp) ]
            , div [ elasticClass ] []
            , renderTopActions entry.message
            ]
         ]
            ++ (if entry.expanded then
                    [ renderMsg entry.message
                    , div
                        [ class [ EBottom, EntryExpanded ] ]
                        [ renderBottomActions entry.message
                        , renderEntryToggler instanceID entry.srcID
                        ]
                    ]
                else
                    [ renderMiniMsg entry.message
                    , div
                        [ class [ EBottom ] ]
                        [ div [ class [ EAct ] ] []
                        , renderEntryToggler instanceID entry.srcID
                        ]
                    ]
               )
        )


renderEntryList : InstanceID -> List LogViewerEntry -> List (Html Msg)
renderEntryList instanceID list =
    List.map (renderEntry instanceID) list



-- END OF THAT


view : Model -> InstanceID -> GameModel -> Html Msg
view model instanceID game =
    let
        logvw =
            getState model instanceID
    in
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
                        [ input [ placeholder "Search..." ] []
                        ]
                    ]
                ]
             ]
                ++ renderEntryList
                    instanceID
                    (case (getLogViewerInstance model.instances instanceID).gateway of
                        Just inst ->
                            Dict.values inst.entries

                        Nothing ->
                            []
                    )
            )
