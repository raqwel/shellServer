#!/usr/bin/env bash
/usr/bin/mkfifo backpipe
IFS=" "
CRLF="\r\n"

normalizePath() {
    TARGET_FILE=$1

    # 対象ファイルのディレクトリまで移動
    # ファイル探索の際に余計についているため
    set -x
    TARGET_FILE=${TARGET_FILE#*/}

    # 対象ファイルのディレクトリ名を取得
    cd `dirname "public/"${TARGET_FILE}`

    # 対象ファイルのファイル名を取得
    TARGET_FILE=${TARGET_FILE##*/}

    # シンボリックリンクでないかを確認
    while [ -L "${TARGET_FILE}" ]
    do
        TARGET_FILE=`readlink ${TARGET_FILE}`
        cd `dirname ${TARGET_FILE}`
        TARGET_FILE=`basename ${TARGET_FILE}`
    done

    PHYS_DIR=`pwd -P`"/public"
    RESULT=${PHYS_DIR}/${TARGET_FILE}
    echo ${RESULT}
    set +x
}

setting404Response() {
    httpStatus="HTTP/1.1 404 Not Found"${CRLF}
    httpDate="Date: $(LANG=en_US.UTF-8 date -uR "+%a, %d %b %Y %T GMT")"${CRLF}
    contentType="Content-Type: text/html;charset=utf-8"${CRLF}
    contentLength="Content-Length: $(wc -c "./public/404.html" | awk '{print $1}')"${CRLF}
    messageBody=$(cat "./public/404.html")
}

setting403Response() {
    httpStatus="HTTP/1.1 403 Forbidden"${CRLF}
    httpDate="Date: $(LANG=en_US.UTF-8 date -uR "+%a, %d %b %Y %T GMT")"${CRLF}
    contentType="Content-Type: text/html;charset=utf-8"${CRLF}
    contentLength="Content-Length: $(wc -c "./public/403.html" | awk '{print $1}')"${CRLF}
    messageBody=$(cat "./public/403.html")
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

    absolutePath=$(cd $(dirname $0)/public; pwd)
    requestPath=$(normalizePath "${2}")

    if [[ ! ${requestPath} =~ ${absolutePath} ]]; then
        setting403Response
        return;
    fi

    fileName="public/${2#/}"

    # 拡張子がなければディレクトリとして読み込む
        #　以下にindex.htmlがあればそれを返す
        #　なければその中のファイルをリストとして返す
        #　ディレクトリ自体なければ404
    if [[ -z $(echo "${fileName}" | grep '\.') ]]; then
        if [[ -e "${fileName}index.html" ]]; then
            setting200Response "${fileName}index.html"
            return;
        elif [[ -d "${fileName}" ]]; then
            showFileList "${fileName}"
            httpStatus="HTTP/1.1 200 OK"${CRLF}
            httpDate="Date: $(LANG=en_US.UTF-8 date -uR "+%a, %d %b %Y %T GMT")"${CRLF}
            contentType="Content-Type: text/html;charset=utf-8"${CRLF}
            #contentLength="Content-Length: $(wc -c "${messageBody}" | awk '{print $1}')"${CRLF}
        else
            setting404Response
            return;
        fi
    else

    # 拡張子があればそのファイルを読み込む
        # ファイルが有ればbodyレスポンスを返す
        # なければ404を返す
        if [[ -e "${fileName}" ]]; then
            setting200Response "${fileName}"
            return;
        else
            setting404Response
            return;
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
while [[ true ]]; do
    # readがないと、HTTPリクエストがないのに処理が行き過ぎてしまうので、headの結果を待つ→リクエストをしっかり受け取ることを行う
    nc -l 3000 -w 1 0<backpipe | head -n1 | (read request; returnHttpResponse "${request}") 1>backpipe
done

