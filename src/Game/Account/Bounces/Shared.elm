module Game.Account.Bounces.Shared exposing (..)


type alias ID =
    String


type CreateError
    = CreateBadRequest
    | CreateUnknown


type UpdateError
    = UpdateBadRequest
    | UpdateUnknown


type RemoveError
    = RemoveBadRequest
    | RemoveUnknown
