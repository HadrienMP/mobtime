start: dev-with-p2p

# ------------------------------------
# Working with old server mode
# ------------------------------------
build: build-with-server
build-with-server:
	TALK_MODE=server pnpm build

dev-with-server:
	TALK_MODE=server pnpm start:dev

# ------------------------------------
# Working with peer to peer
# ------------------------------------
build-with-p2p:
	TALK_MODE=p2p pnpm build

dev-with-p2p:
	TALK_MODE=p2p pnpm start:dev:front

# ------------------------------------
install:
	pnpm install

update:
	nix flake update .

# ------------------------------------
run-doc:
	pnpm start:doc
