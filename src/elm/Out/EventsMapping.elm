module Out.EventsMapping exposing (EventsMapping, batch, create, dispatch, map)

import Out.Events exposing (Event, EventMessage)


type EventsMapping msg
    = EventsMapping (List (EventMessage msg))


create : List (EventMessage msg) -> EventsMapping msg
create list =
    EventsMapping list


map : (a -> b) -> EventsMapping a -> EventsMapping b
map f eventsMapping =
    open eventsMapping
        |> List.map (\eventMessage -> EventMessage eventMessage.name (f << eventMessage.messageFunction))
        |> EventsMapping


batch : List (EventsMapping msg) -> EventsMapping msg
batch eventsMappings =
    eventsMappings
        |> List.map open
        |> List.foldr (++) []
        |> EventsMapping


dispatch : Event -> EventsMapping msg -> List msg
dispatch event eventsMapping =
    open eventsMapping
        |> List.filter (\eventMessage -> eventMessage.name == event.name)
        |> List.map (\eventMessage -> eventMessage.messageFunction event.value )


open : EventsMapping msg -> List (EventMessage msg)
open eventsMapping =
    case eventsMapping of
        EventsMapping list ->
            list
