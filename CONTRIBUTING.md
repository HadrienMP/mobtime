# Contributing

## Playlists

1. Create a new folder in `./public/playlists/` for your playlist. Its name should be in kebab case.
2. Place an image for your playlist in the folder and name it miniature
3. Convert it to webp by running `just to-miniature <file extension of your miniature>` in the playlist folder
4. Create a subfolder `sounds` where you will place the mp3s
5. Make sure your mp3s are 10s or less if possible
6. Normalize the sound levels of sounds by running `just normalize`
7. Create an elm file for your playlist in `./src/elm/Playlist/`
8. Reference your playlist in `./src/elm/Playlist/All.elm`
9. Check that it works, using extreme mode in the settings allows checking if the sounds play correctly.
10. Add one ore more commits with the prefix `feat(<your playlist code>): `
