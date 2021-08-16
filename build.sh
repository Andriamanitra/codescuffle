# builds the app binary inside docker and copies it to ./build/codescuffle
mkdir -p build
docker build --tag codescuffle .
docker create --rm --name scuffle_tmp codescuffle
docker cp scuffle_tmp:/app/codescuffle ./build/codescuffle
docker cp scuffle_tmp:/app/runrequesthandler ./build/runrequesthandler
docker container rm scuffle_tmp
