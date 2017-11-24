module Apps.DBAdmin.Tabs.Servers.Helpers exposing (..)

import Dict exposing (Dict)
import Game.Account.Database.Models as Database
import Game.Meta.Types.Network as Network exposing (NIP)
import Apps.DBAdmin.Models exposing (..)


catchDataWhenFiltering : List String -> NIP -> Database.HackedServer -> Bool
catchDataWhenFiltering filterCache nip value =
    List.member (Network.toString nip) filterCache


applyFilter : Model -> Database.HackedServers -> Database.HackedServers
applyFilter model itens =
    if ((String.length model.servers.filterText) > 0) then
        Dict.filter
            (catchDataWhenFiltering model.servers.filterCache)
            itens
    else
        itens


toggleExpand : String -> Model -> Model
toggleExpand itemId model =
    let
        servers =
            model.servers

        servers_ =
            { servers
                | expanded =
                    if (isEntryExpanded itemId model) then
                        List.filter ((/=) itemId) servers.expanded
                    else
                        itemId :: servers.expanded
            }
    in
        { model | servers = servers_ }


enterEditing : String -> Database.Model -> Model -> Model
enterEditing itemId database model =
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

        model_ =
            item
                |> Maybe.map
                    (\( nip, item ) ->
                        let
                            edit_ =
                                EditingTexts ( start item.label, start item.notes )
                        in
                            updateEditing (Network.toString nip) edit_ model
                    )
    in
        Maybe.withDefault model model_


enterSelectingVirus : String -> Database.Model -> Model -> Model
enterSelectingVirus itemId database model =
    let
        items =
            database.servers

        item =
            items
                |> Dict.filter (\nip _ -> Network.toString nip == itemId)
                |> Dict.toList
                |> List.head

        model_ =
            item
                |> Maybe.map
                    (\( nip, item ) ->
                        let
                            edit_ =
                                item.activeVirus
                                    |> Maybe.map Tuple.first
                                    |> SelectingVirus
                        in
                            updateEditing (Network.toString nip) edit_ model
                    )
    in
        Maybe.withDefault model model_


updateEditing : String -> EditingServers -> Model -> Model
updateEditing itemId value model =
    let
        editing_ =
            Dict.insert itemId value model.serversEditing
    in
        { model | serversEditing = editing_ }


updateSelectingVirus : String -> String -> Model -> Model
updateSelectingVirus virusId itemId model =
    let
        edit_ =
            SelectingVirus (Just virusId)
    in
        updateEditing itemId edit_ model


leaveEditing : String -> Model -> Model
leaveEditing itemId model =
    let
        editing_ =
            Dict.filter (\k _ -> k /= itemId) model.serversEditing
    in
        { model | serversEditing = editing_ }


updateTextFilter : String -> Database.Model -> Model -> Model
updateTextFilter newFilter database model =
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
            model.servers

        servers_ =
            { servers
                | filterText = newFilter
                , filterCache = newFilterCache
            }
    in
        { model | servers = servers_ }
