# Code Scuffle

This will eventually be a coding problem site (I hope)

*scuffle: 1. (noun) a short, confused fight or struggle at close quarters*

**WARNING: This is a work in progress. Exposing the API (in its current state) to the internet would be foolish. Proceed with caution!**

## Project status

Coderunner works but it is not great - the current plan is to use [Piston](https://github.com/engineer-man/piston) at least while developing since it offers a decent selection of languages (and simply works). Later on I would like to at least partially use my own coderunner in order to have more flexibility (ability to show execution/compilation time, maybe provide custom compilation flags, etc.).

Website (frontend) has a working code editor and it communicates with Piston code execution backend and is capable of showing outputs from code runs (stdout/stderr). The site has no backend/database yet, that is the next thing to do.


## Ideas / TODO list (roughly in order of importance)

1. Figure out if this is a terrible idea
1. ~~API definition for Coderunner (OpenAPI)~~ done
1. Tests (Crystal spec, + somehow automatically generate tests from openapi.yaml?)
1. Web Interface (???)
1. Database (???)
1. Dummy coding problems for testing
1. Social features (scuffles, chat, sharing solutions, submitting problems...)
1. Add millions of languages


## Random thoughts

* I want to keep everything open source and open for anyone to contribute
* I'm hesitant to use cloud providers for this project, I'd rather just self-host to keep it simple (+ it makes it super easy and approachable for anyone to host a copy locally for development)
* Oracle Fn seems cool, probably more complicated to set up than docker containers though
* I would like to add some problems that are less about algorithms and more about real use cases, like using standard library to make network requests and interacting with the file system or external programs
