#!/usr/bin/env bash

#################################################################
# user-report.sh - output user data.                            #
#                                                               #
# Site:         https://github.com/rulestux                     #
# Author:       Jean Felipe                                     #
# Maintenance:  Jean Felipe                                     #
#                                                               #
#################################################################
# This script reads and outputs informations about system users,#
# based on system data. Enter the username as parameter to      #
# script call as following:                                     #
#                                                               #
# Usage example:                                                #
#   ./user-report.sh <username>                                 #
#                                                               #
#################################################################
# History:                                                      #
#   v1.0 2025-10-11, Jean Felipe.                               #
#                                                               #
#################################################################
# Tested on:                                                    #
#   zsh v5.9                                                    #
#                                                               #
#################################################################

# implementação de condicional simples com o uso do operador
# lógico '||' 'ou', i. e., executa-se ou o que está de um lado
# ou de outro do operador; caso o primeiro bloco seja executado
# com sucesso, o segundo não será executado; note-se que '2>&1' contém
# uma referência ao stdout '&1' para o qual se redireciona o erro '2':
ls /home/$1 > /dev/null 2>&1 || { echo "User not found."; exit 1; }

# buscar 'user' em /etc/passwd, separar dados com ':' e extrair
# terceiro campo '-f3' com 'cut':
USERID=$(grep $1 /etc/passwd | cut -d ":" -f3)
# extrair dados do campo '-f5' e remover as vírgulas com 'tr -d':
DESC=$(grep $1 /etc/passwd | cut -d ":" -f5 | tr -d ,)
# extrair dados de uso do diretório 'home' e remover campo '-f1':
HOMEUSE=$(du -sh /home/$1 | cut -f1)

clear
echo "══════════════════════════════════════════════"
echo " User $1 Report"
echo "──────────────────────────────────────────────"
echo " UID $USERID"
echo " Name or description: $DESC"
echo
echo " Total use in /home/$1: $HOMEUSE"
echo
echo "Last login:"
lastlog -u $1
echo "══════════════════════════════════════════════"
exit 0
