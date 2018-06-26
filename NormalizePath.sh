#!/usr/bin/env bash

normalizePath() {
    # 見せたいファイルは/publicを起点としたところのみであるため
    local _targetFile="./public${1}"

    # 対象ファイルのディレクトリ名を取得
    cd $(dirname ${_targetFile})

    # 対象ファイルのファイル名を取得
    _targetFile=$(basename ${_targetFile})

    # シンボリックリンクでないかを確認
    while [ -L "${_targetFile}" ]
    do
        _targetFile=$(readlink ${_targetFile})
        cd $(dirname ${_targetFile})
        _targetFile=$(basename ${_targetFile})
    done

    local _dirToTargetFile=$(pwd -P)
    local _result=${_dirToTargetFile}/${_targetFile}
    echo ${_result}
}
