#!/usr/bin/env bash

###########################################################
# list-users_1.0.sh - output users from /etc/passwd       #
#                                                         #
# Site:         https://github.com/rulestux               #
# Author:       Jean Felipe                               #
# Maintenance:  Jean Felipe                               #
#                                                         #
###########################################################
# This script reads and outputs users on /etc/passwd, and #
# there is also the possibility to put it in capital      #
# letters (uppercase) or lowercase.                       #
#                                                         #
# Example:                                                #
#       $ ./list-users_1.3.sh -s -u                       #
#                                                         #
#       In this example, the script returns results in    #
#       alphabetical order and uppercase.                 #
#                                                         #
###########################################################
# History:                                                #
#   v1.0 2025-10-07, Jean Felipe:                         #
#       - Options added: -h, -v, -s, -r.                  #
#   v1.1 2025-10-07, Jean Felipe:                         #
#       - 'case' structure and 'basename'added.           #
#   v1.2 2025-10-07, Jean Felipe:                         #
#       - 'keyflags' and uppercase option implementation; #
#   v1.3 2025-10-07, Jean Felipe:                         #
#       - options overloading and exception handling      #
#       implementation;                                   #
#                                                         #
###########################################################
# Tested on:                                              #
#   zsh v5.9                                              #
#                                                         #
###########################################################

# variável para ler os usuários combinando 'cat' e 'cut',
# cuja utilidade é separar os dados de cada linha da lista
# de usuários em 'passwd', tendo como referência para o
# 'split', passado com a opção '-d' (delimiter) o caractere
# ':', extraindo a coluna '1', passada com a opção '-f':
USERS="$(cat /etc/passwd | cut -d : -f 1)"

# criação de opções, acrescentando o 'basename' para reduzir
# o comprimento do nome do script, sem o caminho:
USE_MESSAGE="
$(basename $0) - [OPTIONS]

    -h - Help menu
    -v - Version
    -s - Order output
    -r - Reverse order
    -u - Return all uppercase
"
VERSION="list-users v1.3"

# criação de keyflags, que retornam 'true' ou 'false',
# i. e., boolean values '1' ou '0', para otimizar o código:
KEY_SORT=0
KEY_SREVERSE=0
KEY_UPPERCASE=0

# implementação das opções em estrutura 'while' 'case';
# o 'while' com 'test' testa se a variável '$1' está
# ocupada com algum número '-n':
while test -n "$1"
do
    # caso sim, o 'case' valida a variável '$1', comparando
    # seu valor e alterando as keyflags quando convier:
    case "$1" in
        -h) echo "$USE_MESSAGE" && exit 0               ;;
        -v) echo "$VERSION" && exit 0                   ;;
        -s) KEY_SORT=1                                  ;;
        -r) KEY_SREVERSE=1                              ;;
        -u) KEY_UPPERCASE=1                             ;;
        # tratamento de exceção && saída de erro #1:
        *) echo                                          \
            "Invalid option. Enter -h for more details." \
            && exit 1                                   ;;
    esac
    # implementação do 'shift' para trazer o valor do que
    # seria a variável '$2' no lugar da variável '$1',
    # para reaproveitar as linhas da estrutura 'while',
    # tornando o código mais enxuto:
    shift
done

# implementação de estruturas de comparação simples para
# retornar a opção testada no 'case', com saída booleana '1';
# com a implementação de sobreposição de opções, o 'echo'
# não poderá ser usado diretamente; então, a solução passa
# a modificar a variável '$USERS', que receberá o retorno
# do comando atrelado às opções fornecidas pelo usuário:
[[ $KEY_SORT -eq 1 ]]      && USERS=$(echo "$USERS" | sort) # ordena alfabeticamente
[[ $KEY_SREVERSE -eq 1 ]]  && USERS=$(echo "$USERS" | sort -r) # alfabético reverso
[[ $KEY_UPPERCASE -eq 1 ]] && USERS=$(echo "$USERS" | tr [a-z] [A-Z]) # tudo para maiúsculas

# saída da variável '$USERS'depois das alterações programadas:
echo "$USERS"
