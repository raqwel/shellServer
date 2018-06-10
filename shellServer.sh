#!/usr/bin/env bash
/usr/bin/mkfifo backpipe
IFS=" "
CRLF="\r\n"

setting404Response() {
    httpStatus="HTTP/1.1 404 Not Found"${CRLF}
    httpDate="Date: $(LANG=en_US.UTF-8 date -uR "+%a, %d %b %Y %T GMT")"${CRLF}
    contentType="Content-Type: text/html;charset=utf-8"${CRLF}
    contentLength="Content-Length: $(wc -c "./public/404.html" | awk '{print $1}')"${CRLF}
    messageBody=$(cat "./public/404.html")
}

setting200Response() {
    httpStatus="HTTP/1.1 200 OK"${CRLF}
    httpDate="Date: $(LANG=en_US.UTF-8 date -uR "+%a, %d %b %Y %T GMT")"${CRLF}
    contentType="Content-Type: text/html;charset=utf-8"${CRLF}
    contentLength="Content-Length: $(wc -c ${1} | awk '{print $1}')"${CRLF}
    messageBody=$(cat "${1}")
}

showFileList() {
    files="${1}/*"
    fileList="<h1>Index of /"${1#*/}"</h1>\n <ul>"
    for file in ${files}; do
        fileList+="<li><a href="/${1#*/}/${file##*/}">${file##*/}</li>\n"
    done
    fileList+="</ul>"
    messageBody="${fileList}"
}

createHttpResponse() {
    set -- ${1}
    fileName="public/${2#/}"
    # 拡張子がなければディレクトリとして読み込む
        #　以下にindex.htmlがあればそれを返す
        #　なければその中のファイルをリストとして返す
        #　ディレクトリ自体なければ404
    if [[ -z $(echo "${fileName}" | grep '\.') ]]; then
        if [[ -e "${fileName}/index.html" ]]; then
            setting200Response "${fileName}/index.html"
        elif [[ -d "${fileName}" ]]; then
            showFileList "${fileName}"
            httpStatus="HTTP/1.1 200 OK"${CRLF}
            httpDate="Date: $(LANG=en_US.UTF-8 date -uR "+%a, %d %b %Y %T GMT")"${CRLF}
            contentType="Content-Type: text/html;charset=utf-8"${CRLF}
            #contentLength="Content-Length: $(wc -c "${messageBody}" | awk '{print $1}')"${CRLF}
        else
            setting404Response
        fi
    else
    # 拡張子があればそのファイルを読み込む
        # ファイルが有ればbodyレスポンスを返す
        # なければ404を返す
        if [[ -e "${fileName}" ]]; then
            setting200Response "${fileName}"
        else
            setting404Response
        fi
    fi
}

returnHttpResponse() {
    createHttpResponse "${1}"

    # HTTPレスポンス組み立て
    httpResponse=${httpStatus}${httpDate}${contentType}${contentLength}${CRLF}${messageBody}

    # レスポンス
    echo ${httpResponse}
}

#  awkの中で関数を実行したい →　どうしてもできない
#  nc -l 3000 0<backpipe | awk '/HTTP/{system("bash -c " createHttpResponse substr($2, 2))}' 1>backpipe
set -x
while [[ true ]]; do
    # readがないと、HTTPリクエストがないのに処理が行き過ぎてしまうので、headの結果を待つ→リクエストをしっかり受け取ることを行う
    nc -l 3000 -w 1 0<backpipe | head -n1 | (read request; returnHttpResponse "${request}") 1>backpipe
done

