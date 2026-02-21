# INSTALL

This project uses devbox and direnv to make the install and shell management easier. You can still install the dependencies in devbox.json by hand

## Devbox

-   Install [Nix](https://nixos.org/download/#download-nix-accordion)
-   Install [devbox](https://www.jetify.com/docs/devbox/installing-devbox)
    -   Makes nix easier to use in a development context
-   Install [DirEnv](https://direnv.net)
    -   Handles the shell configuration of this folder

Then run the following command in the mobtime folder :

```shell
direnv allow
```

## Run

```shell
just start # Will start process compose with the server, the front and the documentation, access the site at http://localhost:3000
just lint # Will fix all elm conventions errors when possible

```
