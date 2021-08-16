# delete all
find languages -maxdepth 1 -mindepth 1 -type d -printf 'scuffle_%f\n' | xargs docker rmi

# build all
for i in $(find languages -maxdepth 1 -mindepth 1 -type d -printf '%f\n';); do
    docker build --tag scuffle_$i -f languages/$i/Dockerfile .
done

