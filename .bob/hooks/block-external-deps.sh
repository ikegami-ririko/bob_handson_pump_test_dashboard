#!/bin/sh
# PreToolUse hook: 外部パッケージのインストールとPythonサーバーの利用をブロックする。
# 標準入力のJSONを受け取り、違反時は stderr に理由を出力して exit 2 で終了する。

input=$(cat)

block() {
  printf '%s\n' "$1" >&2
  exit 2
}

if printf '%s' "$input" | grep -Eq '"tool_name" *: *"execute_command"'; then
  # 外部パッケージのインストール
  if printf '%s' "$input" | grep -Eiq '(pip3?|python3? +-m +pip|uv +pip|poetry|pipenv|conda) +(install|add)|(npm|yarn|pnpm|bun) +(install|i|add|ci)( |"|$)|npx '; then
    block "pip/npm など外部パッケージのインストールは本hands onでは禁止です。"
  fi
  # Pythonなどのサーバー起動
  if printf '%s' "$input" | grep -Eiq 'http\.server|SimpleHTTPServer|flask +run|uvicorn|gunicorn|fastapi|streamlit +run|live-server|http-server|npx +serve'; then
    block "Pythonなどによるサーバーの起動は本hands onでは禁止です。"
  fi
fi

if printf '%s' "$input" | grep -Eq '"tool_name" *: *"(write_file|insert_content|apply_diff|search_and_replace)"'; then
  # 依存関係ファイルの追加
  if printf '%s' "$input" | grep -Eq '"path" *: *"[^"]*(requirements\.txt|package\.json|pyproject\.toml|Pipfile)"'; then
    block "requirements.txt / package.json などの依存関係ファイルの追加・変更は本hands onでは禁止です。"
  fi
fi

exit 0
