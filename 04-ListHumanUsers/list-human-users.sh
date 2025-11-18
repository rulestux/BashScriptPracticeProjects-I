#!/usr/bin/env bash

#################################################################
# list-human-users.sh - outputs human users registered.         #
#                                                               #
# Site:         https://github.com/rulestux                     #
# Author:       Jean Felipe                                     #
# Maintenance:  Jean Felipe                                     #
#                                                               #
#################################################################
# This script reads and outputs system files in order to show   #
# human users registered.                                       #
#                                                               #
# Usage example:                                                #
#   ./list-human-users.sh                                       #
#                                                               #
#################################################################
# History:                                                      #
#   v1.0 2025-10-12, Jean Felipe.                               #
#                                                               #
#################################################################
# Tested on:                                                    #
#   zsh v5.9                                                    #
#                                                               #
#################################################################

# rastreando UIDs de usuários humanos, os quais são registrados
# em faixa diferente de usuários criados pelo próprio sistema,
# cujos dados podem ser encontrados no arquivo '/etc/login.defs';
# com 'tr -s "\t"', as tabulações 'tab' são removidas;
# com 'cut -f2' são extraídos os dados no segundo campo:
MIN_UID=$(grep "^UID_MIN" /etc/login.defs | tr -s "\t" | cut -f2)
MAX_UID=$(grep "^UID_MAX" /etc/login.defs | tr -s "\t" | cut -f2)

# substituindo o Internal Field Separator 'IFS' para ser usado
# com novo valor no 'cat' a seguir; faz-se um backup do 'IFS'
# atribui-se-lhe um novo valor temporário, que será a quebra de
# linha:
DEFAULT_IFS=$IFS
IFS=$'\n'

# criando o cabeçalho de saída com 'tab' como separador,
# adicionando a opção '-e' ao 'echo', que habilita o uso de
# recursos 'escape' para formatação:
echo -e "USER\t\tUID\t\tHOME DIR\t\tNAME OR DESCRIPTION"

# loop for para
for i in $(cat /etc/passwd)
do
    # 'cut -d' delimitador:
    USERID=$(echo $i | cut -d":" -f3)
    # validando a faixa UID de usuários humanos:
    if [[ $USERID -ge $MIN_UID && $USERID -le $MAX_UID ]]
    then
        USER=$(echo $i | cut -d":" -f1)
        USERDESC=$(echo $i | cut -d":" -f5 | tr -d ',')
        USERHOME=$(echo $i | cut -d":" -f6)
        echo -e "$USER\t\t$USERID\t\t$USERHOME\t\t$USERDESC"
    fi
done

# retornando a variável 'IFS' ao valor original:
IFS=$DEFAULT_IFS
