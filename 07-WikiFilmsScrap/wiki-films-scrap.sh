#!/usr/bin/env bash

#################################################################
# wiki-films-scrap.sh                                           #
#                                                               #
# Site:         https://github.com/rulestux                     #
# Author:       Jean Felipe                                     #
# Maintenance:  Jean Felipe                                     #
#                                                               #
#################################################################
# This script returns data about highest-grossing Movies,       #
# according with Wikipaedia, such as a web scraper, and outputs #
# a file in CSV format.                                         #
#                                                               #
# Usage example:                                                #
#                                                               #
#   $ ./wiki-films-scrap.sh -n                                  #
#                                                               #
#       creates a '*.csv' file with names of more rated Movies. #
#                                                               #
# Use '-h' parameter for help.                                  #
#                                                               #
#################################################################
# History:                                                      #
#   v1.0 2025-11-22, Jean Felipe.                               #
#       Script created.                                         #
#                                                               #
#   v1.1 2025-11-23, Jean Felipe.                               #
#       Target changed to Wikipaedia.                           #
#                                                               #
#   v1.2 2025-11-23, Jean Felipe.                               #
#       Bug fixing.                                             #
#                                                               #
#################################################################
# Tested on:                                                    #
#   zsh v5.9                                                    #
#                                                               #
#################################################################

# criação do menu de ajuda, com o comando 'basename', que traz
# o nome do script em '$0', excluindo o restante do caminho:
USE_MESSAGE="
$(basename "$0") - [OPTIONS]

    -h - Help menu.
    -v - Version.
    -g - Extract gross revenues by film.
    -n - Extract only films names.
    -y - Extract release dates.
    With no options, the script returns all data.
"
VERSION="$(basename "$0") v1.2"
TMP_PATH="$(dirname "$0")/tmp"
HTML_FILE="$TMP_PATH/highest_grossing.html"
NAMES_TXT="$TMP_PATH/films_names.txt"
GROSS_TXT="$TMP_PATH/gross.txt"
RELEASE_TXT="$TMP_PATH/releases.txt"
HIGHGROSSFILMS_CSV="highest_grossing_films.csv"

access() {
    # criar diretório para arquivos temporários, caso não exista:
    [ ! -d "$TMP_PATH" ] && mkdir "$TMP_PATH"

    # verificar se o 'curl' não está instalado e perguntar se deve
    # se instalar:
    if [ ! -x "$(which curl)" ]; then
        echo -e "\033[1;5;31mCurl missing!\033[0;0;0m"
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
                sudo apt update
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

    echo -e "\033[5;33mScraping!\033[0;0m"
    sleep 2

    # importar o texto html do site, simulando ser uma requisição de um
    # navegador (-A "Mozilla/5.0"), permitindo seguir redirecionamentos de URL com
    # '-L', e redirecionando a saída, com '-o', para o arquivo 'top_filmes.html':
   curl -A "Mozilla/5.0" -L -o "$HTML_FILE" "https://en.wikipedia.org/wiki/List_of_highest-grossing_films"
}

name() {
    awk '/<table[^>]*wikitable[^"]*sortable[^"]*"/,/<\/table>/' "$HTML_FILE" \
    | grep -E '<th scope="row"' \
    | sed -E 's/.*<a[^>]*>([^<]+)<.*/\1/' \
    > "$NAMES_TXT"
}

gross() {
    awk '/<table[^>]*wikitable[^"]*sortable[^"]*"/,/<\/table>/' "$HTML_FILE" \
    | awk -F'</td>' '
        /<tr>/ { col=0 }
        /<td/ { col++ }
        col==3 {
            match($0, /\$[0-9,]+/, m)
            if (m[0] != "") print m[0]
        }
    ' > "$GROSS_TXT"
}

release() {
    awk '/<table[^>]*wikitable[^"]*sortable[^"]*"/,/<\/table>/' "$HTML_FILE" \
    | awk -F'</td>' '
        /<tr>/ { col=0 }
        /<td/ { col++ }
        col==4 {
            match($0, /[12][0-9]{3}/, m)
            if (m[0] != "") print m[0]
        }
    ' > "$RELEASE_TXT"
}

#################################################################

# testando se o número total de parâmetros passados é
# igual a zero:
if [ "$#" -eq 0 ]; then
    # não havendo parâmetro algum, todas as funções são
    # executadas, como comportamento padrão:
    access
    name
    gross
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
                access
                name
                ;;
            -g)
                access
                name
                gross
                ;;
            -y)
                access
                name
                release
                ;;
            *)
                echo "Invalid option. Enter $(basename "$0") -h for more details."
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
paste -d';' <(cat "$NAMES_TXT" 2>/dev/null) <(cat "$GROSS_TXT" 2>/dev/null) \
    <(cat "$RELEASE_TXT" 2>/dev/null) > "$HIGHGROSSFILMS_CSV"

# verificar se o diretório temporário foi criado e remover:
[ -d "$TMP_PATH" ] && rm -rf "$TMP_PATH"
echo ""
echo "CSV file created, with ';' as delimiter."
