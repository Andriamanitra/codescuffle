# Code Scuffle

RESTful API to run code in various languages inside docker containers, maybe eventually a coding problem site?

*scuffle: 1. (noun) a short, confused fight or struggle at close quarters*

**WARNING: This is a work in progress. Exposing the API (in its current state) to the internet would be foolish. Proceed with caution!**


## Ideas / TODO list (roughly in order of importance)

1. Figure out if this is a terrible idea
1. API definition (OpenAPI)
1. Tests (Crystal spec, + somehow automatically generate tests from openapi.yaml?)
1. Web Interface (???)
1. Database (???)
1. Dummy coding problems for testing
1. Social features (scuffles, chat, sharing solutions, submitting problems...)
1. Add millions of languages


### Random thoughts

* I want to keep everything open source and open for anyone to contribute
* I'm hesitant to use cloud providers for this project, I'd rather just self-host to keep it simple (+ it makes it super easy and approachable for anyone to host a copy locally for development)
* Oracle Fn seems cool, probably more complicated to set up than docker containers though


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


## Building & running the app
Run `./build.sh` to build a statically linked binaries inside docker and `./create_lang_images.sh` to create language docker images. You can check `Dockerfile` and `build.sh` to see exactly what they do, but as the end result you should get a binary that you can run with this command: `./build/codescuffle`
