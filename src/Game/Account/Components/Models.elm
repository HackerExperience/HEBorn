module Game.Account.Components.Models exposing (..)


-- components

type alias Model =
    { available : List Id
    , components : Components
    }

type alias Components =
    Dict Id Component

type alias Id =
    String

type Component =
    { name : String
    , description : String
    , durability : Int | Float
    , spec : Spec 
    }

-- spec



-- server hardware

type alias Hardware =
    { motherboard_id : Maybe Components.Id
    , slots : Dict SlotId Slot
    }

type Slot
    = RAM (Maybe Components.Id)
    | CPU (Maybe Components.Id)
    | HDD (Maybe Components.Id)
    | NIC (Maybe Components.Id)
    | USB (Maybe Components.Id)

--type alias Motherboard =
--    {}