# CodeScuffle Coderunner

RESTful API for running code remotely, implemented using Docker, Crystal-lang and Kemal


## API specification

Every end point is and will be thoroughly documented using OpenAPI Specification in file [openapi.yaml](./openapi.yaml). You can look at the current version in [Swagger editor](https://editor.swagger.io/). Easiest way to import the spec is to click "File -> Import URL" and paste this URL: `https://raw.githubusercontent.com/Andriamanitra/codescuffle/main/openapi.yaml`


## Adding languages

1. Create a Dockerfile under `languages/<language_name>/`. The Dockerfile needs to include `COPY build/runrequesthandler /bin/runreqhandler` and set environment variables `SCUFFLE_COMPILATION_COMMAND` (if separate compilation step is required) and `SCUFFLE_RUN_COMMAND`. In these environment variables you can use `%CODE%` to refer to the path to the source code file and `%EXECUTABLE%` to refer to the output path for the executable binary.
2. Build the docker image for that language either by manually running `docker build --tag scuffle_LANGUAGENAME -f languages/LANGUAGENAME/Dockerfile .` in this directory or use `./create_lang_images.sh` which re-builds *all* language images (which may take a while).


## Abuse prevention measures

* No network access
* Timeouts (**NOT** implemented yet)
* CPU / Memory usage limits (**NOT** implemented yet)
* if you know security stuffs help would be appreciated here


## Building & running
Run `./build.sh` to build a statically linked binaries inside docker and `./create_lang_images.sh` to create language docker images. You can check `Dockerfile` and `build.sh` to see exactly what they do, but as the end result you should get a binary that you can run with this command: `./build/codescuffle`
