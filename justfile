start: 
	process-compose up

install: 
	pnpm install

build *FLAGS:
	pnpm build {{FLAGS}}

lint:
	yes | pnpx elm-review --fix-all

normalize:
	./normalize-library-volume.sh

test watch:
	pnpm run test --watch

[no-cd]
to-miniature extension:
    find . -name "*.{{extension}}" \
        | sed "s/.{{extension}}//" \
        | xargs -I {} magick {}.{{extension}} -resize 214x142^ {}.webp

update:
	devbox update
	pnpm update --latest
	elm-json upgrade --unsafe --yes
