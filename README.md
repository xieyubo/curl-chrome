Curl-Chrome
===
Send HTTP request like a real chrome browser. This project is inspired from https://github.com/lwthiker/curl-impersonate.

## Build

    docker build -t curl-chrome .

## Run

    docker run curl-chrome --chrome -ksSL https://www.wikipedia.org