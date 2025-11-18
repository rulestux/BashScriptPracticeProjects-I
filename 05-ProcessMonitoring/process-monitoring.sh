#!/usr/bin/env bash

#################################################################
# process-monitoring.sh                                         #
#                                                               #
# Site:         https://github.com/rulestux                     #
# Author:       Jean Felipe                                     #
# Maintenance:  Jean Felipe                                     #
#                                                               #
#################################################################
# This script runs as a daemon, monitoring a process entered as #
# parameter, showing messages on screen when the process is     #
# interrupted.                                                  #
#                                                               #
# Usage example:                                                #
#   ./process-monitoring.sh <processname>                       #
#                                                               #
#    Exit with 'CTRL+c'.                                        #
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

# variável para definir o intervalo entre as execuções:
TIME=5

# teste para verificar se algum argumento foi informado em
# qualquer posição '#'; se o valor for zero, mensagem de erro:
if [[ $# -eq 0 ]]
then
    echo "Please, insert a process as argument:"
    echo "\"./process-monitoring.sh <processname>\""
    exit 1
fi

# início de um loop infinito 'enquanto true':
while true
do
    # se 'grep' encontrar o processo contido em '$1', excetuando
    # outros elementos do comando (o próprio grep e a posição
    # '$0' da chamada do comando), apenas aguardar 'sleep $TIME'
    # e voltar a verificar:
    if ps aux | grep $1 | grep -v grep | grep -v $0 > /dev/null
    then
        sleep $TIME
    else
        # do contrário, emitir mensagem de erro, aguardar
        # 'sleep $TIME' e tornar a verificar:
        echo "WARNING! Process $1 is not running!"
        sleep $TIME
    fi
done

