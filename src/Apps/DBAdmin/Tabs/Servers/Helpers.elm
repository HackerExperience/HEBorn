module Apps.DBAdmin.Tabs.Servers.Helpers exposing (..)

import Dict exposing (Dict)
import Game.Account.Database.Models as Database
import Game.Network.Types as Network exposing (NIP)
import Apps.DBAdmin.Models exposing (..)


catchDataWhenFiltering : List String -> NIP -> HackedServer -> Bool
catchDataWhenFiltering filterCache nip value =
    List.member (Network.toString nip) filterCache


applyFilter : DBAdmin -> HackedServers -> HackedServers
applyFilter app itens =
    if ((String.length app.servers.filterText) > 0) then
        Dict.filter
            (catchDataWhenFiltering app.servers.filterCache)
            itens
    else
        itens


toggleExpand : String -> DBAdmin -> DBAdmin
toggleExpand itemId app =
    let
        servers =
            app.servers

        servers_ =
            { servers
                | expanded =
                    if (isEntryExpanded app itemId) then
                        List.filter ((/=) itemId) servers.expanded
                    else
                        itemId :: servers.expanded
            }
    in
        { app | servers = servers_ }


enterEditing : String -> Database.Model -> DBAdmin -> DBAdmin
enterEditing itemId database app =
    let
        items =
            database.servers

        item =
            items
                |> Dict.filter (\nip _ -> Network.toString nip == itemId)
                |> Dict.toList
                |> List.head

        start =
            Maybe.withDefault ""

        app_ =
            item
                |> Maybe.map
                    (\( nip, item ) ->
                        let
                            edit_ =
                                EditingTexts ( start item.label, start item.notes )
                        in
                            updateEditing (Network.toString nip) edit_ app
                    )
    in
        Maybe.withDefault app app_


enterSelectingVirus : String -> Database.Model -> DBAdmin -> DBAdmin
enterSelectingVirus itemId database app =
    let
        items =
            database.servers

        item =
            items
                |> Dict.filter (\nip _ -> Network.toString nip == itemId)
                |> Dict.toList
                |> List.head

        app_ =
            item
                |> Maybe.map
                    (\( nip, item ) ->
                        let
                            edit_ =
                                item.activeVirus
                                    |> Maybe.map Tuple.first
                                    |> SelectingVirus
                        in
                            updateEditing (Network.toString nip) edit_ app
                    )
    in
        Maybe.withDefault app app_


updateEditing : String -> EditingServers -> DBAdmin -> DBAdmin
updateEditing itemId value app =
    let
        editing_ =
            Dict.insert itemId value app.serversEditing
    in
        { app | serversEditing = editing_ }


updateSelectingVirus : String -> String -> DBAdmin -> DBAdmin
updateSelectingVirus virusId itemId app =
    let
        edit_ =
            SelectingVirus (Just virusId)
    in
        updateEditing itemId edit_ app


leaveEditing : String -> DBAdmin -> DBAdmin
leaveEditing itemId app =
    let
        editing_ =
            Dict.filter (\k _ -> k /= itemId) app.serversEditing
    in
        { app | serversEditing = editing_ }


updateTextFilter : String -> Database.Model -> DBAdmin -> DBAdmin
updateTextFilter newFilter database app =
    let
        filterMapFunc nip item =
            [ Tuple.second nip
            , item.password
            , Maybe.withDefault "" item.label
            , Maybe.withDefault "" item.notes
            ]
                |> List.filter (String.contains newFilter)
                |> List.isEmpty
                |> not

        newFilterCache =
            database.servers
                |> Dict.filter filterMapFunc
                |> Dict.keys
                |> List.map Network.toString

        servers =
            app.servers

        servers_ =
            { servers
                | filterText = newFilter
                , filterCache = newFilterCache
            }
    in
        { app | servers = servers_ }
