#!/usr/bin/env bash
/usr/bin/mkfifo backpipe
IFS=" "

createHttpResponse() {
    set -- ${1}
    filename=${2#/}

    # HTTPレスポンスに必要なものを用意
    httpStatus="HTTP/1.1 200 OK"
    crlf="\r\n"
    messageBody=$(cat ${filename})
    responseDate=$(LANG=en_US.UTF-8 date -uR "+%a, %d %b %Y %T GMT")
    httpDate="Date: ${responseDate}"
    # HTTPレスポンス組み立て
    httpResponse=${httpStatus}${crlf}${httpDate}${crlf}${crlf}${messageBody}

    # レスポンス
    echo ${httpResponse}
}

#  awkの中で関数を実行したい →　どうしてもできない
#  nc -l 3000 0<backpipe | awk '/HTTP/{system("bash -c " createHttpResponse substr($2, 2))}' 1>backpipe
set -x
while [[ true ]]; do
    # readがないと、HTTPリクエストがないのに処理が行き過ぎてしまうので、headの結果を待つ→リクエストをしっかり受け取ることを行う
    nc -l 3000 -w 1 0<backpipe | head -n1 | (read request; createHttpResponse "${request}") 1>backpipe
done

