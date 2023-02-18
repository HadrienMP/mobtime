editor:
	nix-shell -p nodejs-16_x --command 'nvim'

run-doc:
	yarn start:doc

run-dev:
	yarn start:dev
