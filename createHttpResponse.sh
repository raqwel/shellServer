#!/usr/bin/env bash

createHttpResponse() {
    # HTTPレスポンスに必要なものを用意
    httpStatus="HTTP/1.1 200 OK"
    crlf="\r\n"
    messageBody=$(cat "${1}")
    responseDate=$(LANG=en_US.UTF-8 date "+%a, %d %b %Y %T GMT")
    httpDate="Date: ${responseDate}"
    # HTTPレスポンス組み立て
    httpResponse=${httpStatus}${crlf}${httpDate}${crlf}${crlf}${messageBody}

    # レスポンス
    echo ${httpResponse}
}