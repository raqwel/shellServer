#!/usr/bin/env bash

set404Response() {
    httpStatus="HTTP/1.1 404 Not Found"${CRLF}
    httpDate="Date: $(LANG=en_US.UTF-8 date -uR "+%a, %d %b %Y %T GMT")"${CRLF}
    contentType="Content-Type: text/html;charset=utf-8"${CRLF}
    contentLength="Content-Length: $(wc -c "./public/404.html" | awk '{print $1}')"${CRLF}
    messageBody=$(cat "./public/404.html")
}

set403Response() {
    httpStatus="HTTP/1.1 403 Forbidden"${CRLF}
    httpDate="Date: $(LANG=en_US.UTF-8 date -uR "+%a, %d %b %Y %T GMT")"${CRLF}
    contentType="Content-Type: text/html;charset=utf-8"${CRLF}
    contentLength="Content-Length: $(wc -c "./public/403.html" | awk '{print $1}')"${CRLF}
    messageBody=$(cat "./public/403.html")
}

set200Response() {
    httpStatus="HTTP/1.1 200 OK"${CRLF}
    httpDate="Date: $(LANG=en_US.UTF-8 date -uR "+%a, %d %b %Y %T GMT")"${CRLF}
    contentType="Content-Type: text/html;charset=utf-8"${CRLF}
    contentLength="Content-Length: $(wc -c ${1} | awk '{print $1}')"${CRLF}
    messageBody=$(cat "${1}")
}