module Game.Account.Bounces.Shared exposing (..)


type alias ID =
    String


type CreateError
    = CreateBadRequest
    | CreateFailed
    | CreateUnknown


type UpdateError
    = UpdateBadRequest
    | UpdateFailed
    | UpdateUnknown


type RemoveError
    = RemoveBadRequest
    | RemoveUnknown
