#!/usr/bin/env bash

#################################################################
# imdb-scraping.sh                                              #
#                                                               #
# Site:         https://github.com/rulestux                     #
# Author:       Jean Felipe                                     #
# Maintenance:  Jean Felipe                                     #
#                                                               #
#################################################################
# This script returns data about top movies published in IMDB,  #
# such as a web scraper, and creates a file with the output     #
# in CSV format.                                                #
#                                                               #
# Usage example:                                                #
#                                                               #
#   $ ./imdb-scraping.sh -n                                     #
#                                                               #
#       creates a '*.csv' file with more rated Movies.          #
#                                                               #
# Use '-h' parameter for help.                                  #
#                                                               #
#################################################################
# History:                                                      #
#   v1.0 2025-11-22, Jean Felipe.                               #
#                                                               #
#################################################################
# Tested on:                                                    #
#   zsh v5.9                                                    #
#                                                               #
#################################################################

# criação do menu de ajuda, com o comando 'basename', que traz
# o nome do script em '$0', excluindo o restante do caminho:
USE_MESSAGE="
$(basename $0) - [OPTIONS]

    -h - Help menu.
    -v - Version.
    -n - Extract only movie names from Top Movies in IMDB.
    -r - Extract ratings.
    -y - Extract release dates.
    With no options, the script returns all data.
"
VERSION="$(basename $0)v1.0"
TMP_PATH="$(pwd)/tmp"
HTML_FILE="$TMP_PATH/top_movies.html"
NAMES_TXT="$TMP_PATH/movie_names.txt"
RATINGS_TXT="$TMP_PATH/ratings.txt"
RELEASE_TXT="$TMP_PATH/releases.txt"
TOPMOVIES_CSV="topmovies.csv"

# importando o texto html do site e redirecionando a saída para
# o arquivo 'top_filmes.html':
access() {
    touch "$HTML_FILE"
    curl -o "$HTML_FILE" "https://www.imdb.com/chart/top"
}

name() {
    sed -n 's/.*text--reduced">[0-9]\+.\s*\(.*\)<\/h3>.*/\1/p' \
    "$HTML_FILE" > "$NAMES_TXT"
}

rating() {
    sed -n 's/.*ipc-rating-star--rating">\([0-9]\+\.[0-9]\+\).*/\1/p' \
    "$HTML_FILE" > "$RATINGS_TXT"
}

release() {
    sed -n 's/.*">\([1-2][0,9][0-2,9][0-9]\)<\/span>.*/\1/p' \
    "$HTML_FILE" > "$RELEASE_TXT"
}

#################################################################

# criar diretório para arquivos temporários, caso não exista:
[ ! -d "$TMP_PATH" ] && mkdir "$TMP_PATH"

# verificar se o 'curl' não está instalado e perguntar se deve
# se instalar:
if [ ! -x "$(which curl)" ]; then
    echo "\033[1;5;31mCurl missing!"
    sleep 3
    echo -e "This script uses curl to access Websites.
Would you want to install it?"
    read -p "(Y/n): " INSTALL_OPT

    # transformar qualquer opção passada em 'INSTALL_OPT'
    # em minúsculas, com 'tr':
    INSTALL_OPT=$(echo "$INSTALL_OPT" | tr '[:upper:]' '[:lower:]')

    # testar se a entrada é nula, para redefinir para o
    # padrão 'y':
    if [ -z "$INSTALL_OPT" ]; then
        INSTALL_OPT="y"
    fi

    # case para as ações:
    case "$INSTALL_OPT" in
        y)
            sudo apt install curl -y
            ;;
        n)
            echo "Exiting script." && exit 0
            ;;
        # tratamento de exceção && saída de erro #1:
        *)
            echo "Invalid option. Enter $(basename $0) -h for more details."\
            && exit 1
            ;;
    esac
fi

#################################################################

# testando se o número total de parâmetros passados é
# igual a zero:
if [ "$#" -eq 0 ]; then
    # não havendo parâmetro algum, todas as funções são
    # executadas, como comportamento padrão:
    name
    rating
    release
else
    # 'while' com um 'test' da posição '$1' que verifica
    # se ela não está vazia, i. e., enquanto passar
    # por 'shift' e a variável '$1' não estiver vazia,
    # verificar o 'case':
    while test -n "$1"; do
        case "$1" in
            -h)
                echo "$USE_MESSAGE" && exit 0
                ;;
            -v)
                echo "$VERSION" && exit 0
                ;;
            -n)
                name
                ;;
            -r)
                name
                rating
                ;;
            -y)
                name
                release
                ;;
            *)
                echo "Invalid option. Enter $(basename $0) -h for more details."
                ;;
        esac
        # 'shift', para trazer para a posição '$1'
        # quaisquer outros parâmetros subsequentes:
        shift
    done
fi

# unir (colar) todo o conteúdo dos arquivos gerados em um único
# arquivo, encaminhando eventuais mensagens de erro para
# '/dev/null', caso algum arquivo não exista; '<(cat)' executa
# o 'cat' em um subshell:
paste -d',' <(cat "$NAMES_TXT" 2>/dev/null) <(cat "$RATINGS_TXT" 2>/dev/null) \
    <(cat "$RELEASE_TXT" 2>/dev/null) > top_filmes.csv

# verificar se o diretório temporário foi criado e remover:
[ -d "$TMP_PATH" ] && rm -rf "$TMP_PATH"
