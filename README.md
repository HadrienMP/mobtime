[![Awesome](https://awesome.re/badge.svg)](https://github.com/mobtimeapp/awesome-mobbing)

# Mobtime
The most fun web timer to time mob or pair turns. At the end of each turn, it plays a fun sound from a playlist.

## Features
- Synced turn timer (with websockets) 
- Plays a random music (from a playlist) at the end of each turn
- Synced pomodoro timer
- Displays the current driver and navigator

## Design doc
It's just starting for now but it's hosted here :
https://mobtime-doc.onrender.com

## Technologies
- [Yjs](https://yjs.dev/), a js framework to enable peer to peer applications
- [y-webrtc](https://github.com/yjs/y-webrtc), make Yjs share its data through webrtc
  - Thus it needs a signaling server to link peer from a room
- [y-indexeddb](https://github.com/yjs/y-indexeddb), make Yjs persist your data in the indexed db of your browser
- [Elm](https://elm-lang.org/), the most awesome language for the front-end
- [elm-css](https://github.com/rtfeldman/elm-css), typesafe css in elm
- [Howler](https://howlerjs.com/) to work with sound