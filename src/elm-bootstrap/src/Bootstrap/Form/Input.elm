module Bootstrap.Form.Input exposing
    ( text, password, datetimeLocal, date, month, time, week, number, email, url, search, tel, color
    , id, small, large, value, disabled, readonly, onInput, placeholder, attrs, Option
    , success, danger
    )

{-| This module allows you to create Bootstrap styled HTML 5 inputs.


# Input types

@docs text, password, datetimeLocal, date, month, time, week, number, email, url, search, tel, color


# Options

@docs id, small, large, value, disabled, readonly, onInput, placeholder, attrs, Option


# Validation

You can indicate success or invalid input using these functions.

@docs success, danger

-}

import Bootstrap.Form.FormInternal as FormInternal
import Bootstrap.General.Internal exposing (ScreenSize(..), screenSizeOption)
import Html
import Html.Attributes as Attributes
import Html.Events as Events


{-| Opaque type representing a composable input
-}
type Input msg
    = Input { options : List (Option msg) }


{-| Opaque type representing legal input configuration options
-}
type Option msg
    = Size ScreenSize
    | Id String
    | Type InputType
    | Disabled Bool
    | Value String
    | OnInput (String -> msg)
    | Validation FormInternal.Validation
    | Placeholder String
    | Readonly Bool
    | Attrs (List (Html.Attribute msg))


type InputType
    = Text
    | Password
    | DatetimeLocal
    | Date
    | Month
    | Time
    | Week
    | Number
    | Email
    | Url
    | Search
    | Tel
    | Color


type alias Options msg =
    { tipe : InputType
    , id : Maybe String
    , size : Maybe ScreenSize
    , disabled : Bool
    , value : Maybe String
    , placeholder : Maybe String
    , onInput : Maybe (String -> msg)
    , validation : Maybe FormInternal.Validation
    , readonly : Bool
    , attributes : List (Html.Attribute msg)
    }


{-| Create an input with type="text"

    Input.text
        [ Input.id "myinput"
        , Input.small
        , Input.onInput MyInputMsg
        ]

-}
text : List (Option msg) -> Html.Html msg
text =
    input Text


{-| Create an input with type="password"
-}
password : List (Option msg) -> Html.Html msg
password =
    input Password


{-| Create an input with type="datetime-local"
-}
datetimeLocal : List (Option msg) -> Html.Html msg
datetimeLocal =
    input DatetimeLocal


{-| Create an input with type="date"
-}
date : List (Option msg) -> Html.Html msg
date =
    input Date


{-| Create an input with type="month"
-}
month : List (Option msg) -> Html.Html msg
month =
    input Month


{-| Create an input with type="time"
-}
time : List (Option msg) -> Html.Html msg
time =
    input Time


{-| Create an input with type="week"
-}
week : List (Option msg) -> Html.Html msg
week =
    input Week


{-| Create an input with type="number"
-}
number : List (Option msg) -> Html.Html msg
number =
    input Number


{-| Create an input with type="email"
-}
email : List (Option msg) -> Html.Html msg
email =
    input Email


{-| Create an input with type="url"
-}
url : List (Option msg) -> Html.Html msg
url =
    input Url


{-| Create an input with type="search"
-}
search : List (Option msg) -> Html.Html msg
search =
    input Search


{-| Create an input with type="tel"
-}
tel : List (Option msg) -> Html.Html msg
tel =
    input Tel


{-| Create an input with type="color"
-}
color : List (Option msg) -> Html.Html msg
color =
    input Color


input : InputType -> List (Option msg) -> Html.Html msg
input tipe options =
    create tipe options |> view


create : InputType -> List (Option msg) -> Input msg
create tipe options =
    Input { options = Type tipe :: options }


view : Input msg -> Html.Html msg
view (Input { options }) =
    Html.input
        (toAttributes options)
        []


{-| Option to make an input shorter (in height)
-}
small : Option msg
small =
    Size SM


{-| Option to make an input taller (in height)
-}
large : Option msg
large =
    Size LG


{-| Options/shorthand for setting the id of an input
-}
id : String -> Option msg
id id_ =
    Id id_


{-| Use this function to handle any Html.Attribute option you wish for your input
-}
attrs : List (Html.Attribute msg) -> Option msg
attrs attrs_ =
    Attrs attrs_


{-| Shorthand for setting the value attribute of an input
-}
value : String -> Option msg
value value_ =
    Value value_


{-| Shorthand for setting the placeholder attribute of an input
-}
placeholder : String -> Option msg
placeholder value_ =
    Placeholder value_


{-| Shorthand for assigning an onInput handler for an input
-}
onInput : (String -> msg) -> Option msg
onInput toMsg =
    OnInput toMsg


{-| Shorthand for setting the disabled attribute of an input
-}
disabled : Bool -> Option msg
disabled disabled_ =
    Disabled disabled_


{-| Shorthand for setting the readonly attribute of an input
-}
readonly : Bool -> Option msg
readonly readonly_ =
    Readonly readonly_


{-| Option to add a success marker icon for your input.
-}
success : Option msg
success =
    Validation FormInternal.Success


{-| Option to add a danger marker icon for your input.
-}
danger : Option msg
danger =
    Validation FormInternal.Danger


toAttributes : List (Option msg) -> List (Html.Attribute msg)
toAttributes modifiers =
    let
        options =
            List.foldl applyModifier defaultOptions modifiers
    in
    [ Attributes.class "form-control"
    , Attributes.disabled options.disabled
    , Attributes.readonly options.readonly
    , typeAttribute options.tipe
    ]
        ++ ([ Maybe.map Attributes.id options.id
            , Maybe.andThen sizeAttribute options.size
            , Maybe.map Attributes.value options.value
            , Maybe.map Attributes.placeholder options.placeholder
            , Maybe.map Events.onInput options.onInput
            , Maybe.map validationAttribute options.validation
            ]
                |> List.filterMap identity
           )
        ++ options.attributes


defaultOptions : Options msg
defaultOptions =
    { tipe = Text
    , id = Nothing
    , size = Nothing
    , disabled = False
    , value = Nothing
    , placeholder = Nothing
    , onInput = Nothing
    , validation = Nothing
    , readonly = False
    , attributes = []
    }


applyModifier : Option msg -> Options msg -> Options msg
applyModifier modifier options =
    case modifier of
        Size size_ ->
            { options | size = Just size_ }

        Id id_ ->
            { options | id = Just id_ }

        Type tipe ->
            { options | tipe = tipe }

        Disabled val ->
            { options | disabled = val }

        Value value_ ->
            { options | value = Just value_ }

        Placeholder value_ ->
            { options | placeholder = Just value_ }

        OnInput onInput_ ->
            { options | onInput = Just onInput_ }

        Validation validation_ ->
            { options | validation = Just validation_ }

        Readonly val ->
            { options | readonly = val }

        Attrs attrs_ ->
            { options | attributes = options.attributes ++ attrs_ }


sizeAttribute : ScreenSize -> Maybe (Html.Attribute msg)
sizeAttribute size =
    Maybe.map
        (\s -> Attributes.class <| "form-control-" ++ s)
        (screenSizeOption size)


typeAttribute : InputType -> Html.Attribute msg
typeAttribute inputType =
    Attributes.type_ <|
        case inputType of
            Text ->
                "text"

            Password ->
                "password"

            DatetimeLocal ->
                "datetime-local"

            Date ->
                "date"

            Month ->
                "month"

            Time ->
                "time"

            Week ->
                "week"

            Number ->
                "number"

            Email ->
                "email"

            Url ->
                "url"

            Search ->
                "search"

            Tel ->
                "tel"

            Color ->
                "color"


validationAttribute : FormInternal.Validation -> Html.Attribute msg
validationAttribute validation =
    Attributes.class <| FormInternal.validationToString validation
