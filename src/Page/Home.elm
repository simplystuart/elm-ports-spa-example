module Page.Home exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as D
import Task
import Time


-- MODEL


type PageData
    = Loading
    | Success


type alias Model =
    { pageData : PageData }


init : ( Model, Cmd Msg )
init =
    ( Model Loading, Task.perform GotTime Time.now )



-- UPDATE


type Msg
    = GotTime Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTime time ->
            ( { model | pageData = Success }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.pageData of
        Loading ->
            div [] [ text "Loading.." ]

        Success ->
            div []
                [ h1 [] [ text "Home" ]
                , div [] [ a [ href "/inner" ] [ text "Inner" ] ]
                ]
