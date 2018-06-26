#!/usr/bin/env bash
source Constant.sh
source ResponseCollection.sh
source HTTPResponse.sh

/usr/bin/mkfifo backpipe

#  awkの中で関数を実行したい →　どうしてもできない
#  nc -l 3000 0<backpipe | awk '/HTTP/{system("bash -c " createHttpResponse substr($2, 2))}' 1>backpipe
while [[ true ]]; do
    # readがないと、HTTPリクエストがないのに処理が行き過ぎてしまうので、headの結果を待つ→リクエストをしっかり受け取ることを行う
    nc -l 3000 -w 1 0<backpipe | head -n1 | (read request; writeHttpResponse "${request}") 1>backpipe
done

