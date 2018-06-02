#!/usr/bin/env bash
/usr/bin/mkfifo backpipe

createHttpResponse() {
    # HTTPレスポンスに必要なものを用意
    httpStatus="HTTP/1.1 200 OK"
    crlf="\r\n"
    messageBody=$(cat ${1})
    responseDate=$(LANG=en_US.UTF-8 date "+%a, %d %b %Y %T GMT")
    httpDate="Date: ${responseDate}"
    # HTTPレスポンス組み立て
    httpResponse=${httpStatus}${crlf}${httpDate}${crlf}${crlf}${messageBody}

    # レスポンス
    echo ${httpResponse}
}

test() {
    IFS=" "
    set -- ${1}
    createHttpResponse ${2#/}
}
#  awkの中で関数を実行したい →　どうしてもできない
#  nc -l 3000 0<backpipe | awk '/HTTP/{system("bash -c " createHttpResponse substr($2, 2))}' 1>backpipe
set -x
while [[ true ]]; do
    nc -l 3000 -w 1 0<backpipe | head -n1 | (read request; test "${request}") 1>backpipe
done

