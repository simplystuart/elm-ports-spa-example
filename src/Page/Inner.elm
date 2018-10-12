port module Page.Inner exposing (Model, Msg, init, update, subscriptions, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as D
import Json.Encode as E
import Process
import Task


-- PORTS


port innerPortCmd : E.Value -> Cmd msg


port innerPortSub : (E.Value -> msg) -> Sub msg



-- MODEL


type PageData
    = Loading
    | Success Int


type alias Model =
    { pageData : PageData }


init : ( Model, Cmd Msg )
init =
    ( Model Loading, Task.perform Ready <| Process.sleep 0 )



-- UPDATE


type Msg
    = GotInnerPort (Result D.Error Int)
    | Ready ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotInnerPort result ->
            case result of
                Err _ ->
                    ( model, Cmd.none )

                Ok num ->
                    ( Model (Success num), Cmd.none )

        Ready _ ->
            ( model, innerPortCmd <| E.int 0 )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    innerPortSub <| GotInnerPort << D.decodeValue D.int



-- VIEW


view : Model -> Html Msg
view model =
    case model.pageData of
        Loading ->
            div [] [ h1 [] [ text "Inner" ], text "Loading..." ]

        Success num ->
            div []
                [ h1 [] [ text "Inner" ]
                , div [] [ text <| String.fromInt num ]
                , div [] [ a [ href "/" ] [ text "Home" ] ]
                ]
