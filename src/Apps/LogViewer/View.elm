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
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Menu.View exposing (menuView, menuNormalEntry, menuEditingEntry, menuFilter)
import Apps.LogViewer.Style exposing (Classes(..))
import Date.Format as DateFormat exposing (format)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "logvw"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style



-- VIEW WRAPPER


renderAddr : IP -> List (Html Msg)
renderAddr addr =
    if (isLocalHost addr) then
        [ span [ class [ IcoHome, ColorLocal ] ] []
        , text " "
        , span [ class [ IdLocal, ColorLocal ] ] [ text addr ]
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


renderFile : FileName -> List (Html Msg)
renderFile fileName =
    [ span [] [ text fileName ] ]


renderButton : LogID -> Classes -> List (Html Msg)
renderButton logID btn =
    [ text " "
    , span
        ([ class [ btn, BottomButton ] ]
            ++ (case btn of
                    BtnEdit ->
                        [ onClick (EnterEditing logID) ]

                    BtnApply ->
                        [ onClick (ApplyEditing logID) ]

                    BtnCancel ->
                        [ onClick (LeaveEditing logID) ]

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


renderFlag : Classes -> List (Html Msg)
renderFlag flag =
    [ text " "
    , span [ class [ flag ] ] []
    ]


renderFlags : List Classes -> List (Html Msg)
renderFlags =
    List.map renderFlag
        >> List.concat
        >> List.tail
        >> Maybe.withDefault []


renderMsg : LogEventMsg -> Html Msg
renderMsg msg =
    div [ class [ EData ] ]
        (case msg of
            LogIn addr user ->
                (renderAddr addr)
                    ++ [ span [] [ text " logged in as " ] ]
                    ++ (renderUser user)

            LogInto dest ->
                [ span [] [ text "Logged into " ] ]
                    ++ (renderAddr dest)

            Connection actor src dest ->
                (renderAddr actor)
                    ++ [ span [] [ text "bounced connection from " ] ]
                    ++ (renderAddr src)
                    ++ [ span [] [ text " to " ] ]
                    ++ (renderAddr dest)

            DownloadBy fileName destIP ->
                [ span [] [ text "File " ] ]
                    ++ (renderFile fileName)
                    ++ [ span [] [ text " downloaded by " ] ]
                    ++ renderAddr destIP

            DownloadFrom fileName srcIP ->
                [ span [] [ text "File " ] ]
                    ++ (renderFile fileName)
                    ++ [ span [] [ text " downloaded from " ] ]
                    ++ (renderAddr srcIP)

            Invalid msg ->
                [ span [] [ text "Corrupted: " ]
                , span [] [ text msg ]
                ]
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


renderEditing : LogID -> String -> Html Msg
renderEditing logID src =
    input
        [ class [ EData, BoxifyMe ]
        , value src
        , onInput (UpdateEditing logID)
        ]
        []


renderTopActions : LogViewerEntry -> Html Msg
renderTopActions entry =
    div [ class [ ETActMini ] ]
        -- TODO: Catch the flags for real
        (renderFlags [ BtnUser, BtnEdit, BtnLock ])


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

                Editing _ ->
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
    case entry.status of
        Editing x ->
            renderEditing entry.srcID x

        _ ->
            if (isEntryExpanded entry) then
                renderMsg entry.message
            else
                renderMiniMsg entry.message


renderBottom : LogViewerEntry -> Html Msg
renderBottom entry =
    case entry.status of
        Editing _ ->
            div
                [ class [ EBottom ] ]
                [ renderBottomActions entry ]

        _ ->
            if (isEntryExpanded entry) then
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


menuInclude : LogViewerEntry -> List (Attribute Msg)
menuInclude entry =
    case entry.status of
        Normal _ ->
            [ menuNormalEntry entry.srcID ]

        Editing _ ->
            [ menuEditingEntry entry.srcID ]

        _ ->
            []


renderEntry : LogViewerEntry -> Html Msg
renderEntry entry =
    div
        ([ class
            (if (isEntryExpanded entry) then
                [ Entry, EntryExpanded ]
             else
                [ Entry ]
            )
         ]
            ++ (menuInclude entry)
        )
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
view game ({ app } as model) =
    div [ menuFilter ]
        ([ menuView model
         , div [ class [ HeaderBar ] ]
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
                        , value app.filtering
                        , onInput UpdateFilter
                        ]
                        []
                    ]
                ]
            ]
         ]
            ++ (app.entries
                    |> Dict.filter
                        (\k v -> String.contains app.filtering v.src)
                    |> Dict.values
                    |> renderEntryList
               )
        )
