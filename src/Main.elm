module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, blockquote, button, cite, div, footer, h1, span, text)
import Html.Attributes exposing (class, id, title)



-- TODO: Integrae the API to get the actual quotes
---- MODEL ----


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row mx-lg-3 mt-md-5 mt-sm-3 mt-1" ]
            [ div [ class "col-sm-7 text-sm-left text-center" ]
                [ h1 [ class "text-success" ]
                    [ span [ class "font-khula" ]
                        [ text "Random" ]
                    , span [ class "font-heebo" ]
                        [ text "Quotes" ]
                    ]
                ]
            , div [ class "col-sm-5 text-sm-right text-center" ]
                [ button [ class "btn btn-outline-success font-heebo font-weight-bold" ]
                    [ span [ class "d-none d-md-inline" ]
                        [ text "Get another" ]
                    , span [ class "d-md-none" ]
                        [ text "Refresh" ]
                    , span [ class "d-none d-md-inline" ]
                        [ text "awesome" ]
                    , text "quote      "
                    ]
                ]
            ]
        , div [ class "row mt-md-5 mt-2" ]
            [ div [ class "col-md-2 text-center text-md-right" ]
                [ span [ class "text-success d-none d-lg-inline", id "big-quotation-mark" ]
                    [ text "“" ]
                ]
            , div [ class "col-md" ]
                [ blockquote [ class "blockquote" ]
                    [ div [ class "mb-5 text-center text-md-left", id "quote-content" ]
                        [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante.        " ]
                    , footer [ class "blockquote-footer text-right" ]
                        [ span []
                            [ text "Someone famous" ]
                        , cite [ title "Source Title" ]
                            [ text "(Source Title)" ]
                        ]
                    ]
                ]
            , div [ class "col-md-2 text-center text-md-left" ]
                [ div [ id "tweet-container" ]
                    []
                ]
            ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
