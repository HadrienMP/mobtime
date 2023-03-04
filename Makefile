# ------------------------------------
# Working with old server mode
# ------------------------------------
build: build-with-server
build-with-server:
	TALK_MODE=server yarn build

dev-with-server:
	TALK_MODE=server yarn start:dev

# ------------------------------------
# Working with peer to peer
# ------------------------------------
build-with-p2p:
	TALK_MODE=p2p yarn build

dev-with-p2p:
	TALK_MODE=p2p yarn start:dev

# ------------------------------------
install : 
	yarn install

# ------------------------------------
# Run vim in nix with node 16 
# - allows elm language server to work
# ------------------------------------
vim:
	nix-shell -p nodejs-16_x --command 'nvim'

# ------------------------------------
run-doc:
	yarn start:doc
