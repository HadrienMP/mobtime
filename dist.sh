./elm-make.sh
cd public || exit
mkdir dist
zip -r dist/dist.zip ./*