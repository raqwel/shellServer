/usr/bin/mkfifo backpipe

while [[ true ]]; do
  # ファイル名取得
  fileName=$(nc -l 3000 | awk '/HTTP/{print substr($2, 2)}')

  # HTTPレスポンスｎ必要なものを用意
  httpStatus="HTTP/1.1 200 OK"
  crlf="\r\n"
  messageBody=$(cat "${fileName}")

  # HTTPレスポンス組み立て
  httpResponse=${httpStatus}${crlf}${crlf}${messageBody}

  # レスポンス
  echo ${httpResponse} | nc -l 3000
done
