# Code Scuffle

RESTful API to run code in various languages inside docker containers, maybe eventually a coding problem site?

*scuffle: 1. (noun) a short, confused fight or struggle at close quarters*

**WARNING: This is a work in progress. Exposing the API (in its current state) to the internet would be foolish. Proceed with caution!**


## Ideas / TODO list (roughly in order of importance)

1. Figure out if this is a terrible idea
1. API definition (OpenAPI?)
1. Tests (Crystal spec)
1. Web Interface (???)
1. Database (???)
1. Dummy coding problems for testing
1. Social features (scuffles, chat, sharing solutions, submitting problems...)
1. Add millions of languages


### Random thoughts

* I want to keep everything open source and open for anyone to contribute
* I'm hesitant to use cloud providers for this project, I'd rather just self-host to keep it simple (+ it makes it super easy and approachable for anyone to host a copy locally for development)
* Oracle Fn seems cool, probably more complicated to set up than docker containers though


## Adding languages

1. Create a Dockerfile (with ENTRYPOINT that accepts code as an argument) under `languages/<language_name>/`
2. `cd languages/<language_name>`
3. `docker build --tag scuffle_<language_name> .`
4. Done! Languages are loaded automatically on start-up based on the docker image's tag name.


## Abuse prevention measures

* No network access
* Timeouts (**NOT** implemented yet)
* CPU / Memory usage limits (**NOT** implemented yet)
* if you know security stuffs help would be appreciated here
