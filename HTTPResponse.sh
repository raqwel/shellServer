#!/usr/bin/env bash
source NormalizePath.sh

createFileList() {
    local _files="${1}/*"
    local _fileList="<h1>Index of /"${1##*/}"</h1>\n <ul>"
    for file in ${_files}; do
        _fileList+="<li><a href="/${1##*/}/${file##*/}">${file##*/}</li>\n"
    done
    _fileList+="</ul>"
    messageBody="${_fileList}"
}

createHttpResponse() {
    set -- ${1}

    local _absolutePath=$(cd $(dirname $0)/public; pwd)
    local _requestPath=$(normalizePath "${2}")

    if [[ ! "${_requestPath}" =~ "${_absolutePath}" ]]; then
        set403Response
        return;
    fi

    fileName="${_requestPath}"
    # 拡張子がなければディレクトリとして読み込む
        #　以下にindex.htmlがあればそれを返す
        #　なければその中のファイルをリストとして返す
        #　ディレクトリ自体なければ404
    if [[ -z $(echo "${fileName}" | grep '\.') ]]; then
        if [[ -e "${fileName}/index.html" ]]; then
            set200Response "${fileName}/index.html"
            return;
        elif [[ -d "${fileName}" ]]; then
            createFileList "${fileName}"
            httpStatus="HTTP/1.1 200 OK"${CRLF}
            httpDate="Date: $(LANG=en_US.UTF-8 date -uR "+%a, %d %b %Y %T GMT")"${CRLF}
            contentType="Content-Type: text/html;charset=utf-8"${CRLF}
            #contentLength="Content-Length: $(wc -c "${messageBody}" | awk '{print $1}')"${CRLF}
        else
            set404Response
            return;
        fi
    else

    # 拡張子があればそのファイルを読み込む
        # ファイルが有ればbodyレスポンスを返す
        # なければ404を返す
        if [[ -e "${fileName}" ]]; then
            set200Response "${fileName}"
            return;
        else
            set404Response
            return;
        fi
    fi
}

writeHttpResponse() {
    createHttpResponse "${1}"

    # HTTPレスポンス組み立て
    local _httpResponse=${httpStatus}${httpDate}${contentType}${contentLength}${CRLF}${messageBody}

    # レスポンス
    echo ${_httpResponse}
}