#!/usr/bin/env bash
/usr/bin/mkfifo backpipe
IFS=" "
CRLF="\r\n"

createHttpResponse() {
    set -- ${1}
    fileName=${2#/}

    # HTTPレスポンスに必要なものを用意

    httpStatus="HTTP/1.1 200 OK"${CRLF}
    httpDate="Date: $(LANG=en_US.UTF-8 date -uR "+%a, %d %b %Y %T GMT")"${CRLF}
    contentType="Content-Type: text/html;charset=utf-8"${CRLF}
    contentLength="Content-Length: $(wc -c "${fileName}" | awk '{print $1}')"${CRLF}
    messageBody=$(cat ${fileName})

    # HTTPレスポンス組み立て
    httpResponse=${httpStatus}${httpDate}${contentType}${contentLength}${CRLF}${messageBody}

    # レスポンス
    echo ${httpResponse}
}

#  awkの中で関数を実行したい →　どうしてもできない
#  nc -l 3000 0<backpipe | awk '/HTTP/{system("bash -c " createHttpResponse substr($2, 2))}' 1>backpipe
#set -x
while [[ true ]]; do
    # readがないと、HTTPリクエストがないのに処理が行き過ぎてしまうので、headの結果を待つ→リクエストをしっかり受け取ることを行う
    nc -l 3000 -w 1 0<backpipe | head -n1 | (read request; createHttpResponse "${request}") 1>backpipe
done

