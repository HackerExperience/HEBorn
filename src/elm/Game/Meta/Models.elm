module Game.Meta.Models exposing (..)


type alias MetaModel =
    { online : Int }


initialMetaModel : MetaModel
initialMetaModel =
    { online = 0 }
