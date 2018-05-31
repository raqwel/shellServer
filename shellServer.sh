#!/usr/bin/env bash
/usr/bin/mkfifo backpipe

createHttpResponse() {
# HTTPレスポンスｎ必要なものを用意
  httpStatus="HTTP/1.1 200 OK"
  crlf="\r\n"
  messageBody=$(cat "${fileName}")
  # ex) Date: Tue, 15 Nov 1994 08:12:31 GMT
#  LANG=en_US.UTF-8
  responseDate=$(LANG=en_US.UTF-8 date "+%a, %d %b %Y %T GMT")
  httpDate="Date: ${responseDate}"
  # HTTPレスポンス組み立て

  httpResponse=${httpStatus}${crlf}${httpDate}${crlf}${crlf}${messageBody}

  # レスポンス
  echo ${httpResponse}
}
while [[ true ]]; do
#  awkの中で関数を実行したい
  nc -l 3000 0<backpipe | awk '/HTTP/{system("bash -c 'createHttpResponse' substr($2, 2)")}' 1>backpipe
done
