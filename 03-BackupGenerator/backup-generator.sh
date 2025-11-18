#!/usr/bin/env bash

#################################################################
# backup-generator.sh - creates a backup for the /home/user/    #
# directory.                                                    #
#                                                               #
# Site:         https://github.com/rulestux                     #
# Author:       Jean Felipe                                     #
# Maintenance:  Jean Felipe                                     #
#                                                               #
#################################################################
# This script creates a "backup_home.tgz" file compressing      #
# the /home/user/ directory.                                    #
#                                                               #
# Usage example:                                                #
#   ./backup-generator.sh                                       #
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

BACKDIR=$HOME/BACKUP

# testando em estrutura condicional se o diretório de backup
# já existe; caso NÃO exista, criar diretório e caminho '-p':
if [ ! -d $BACKDIR ]
then
    echo "Creating \""$BACKDIR"\" directory..."
    mkdir -p $BACKDIR
fi

# 'find' para buscar arquivos '*.tgz' criados nos últimos 7 dias
# com as opções '-ctime 7 -name' e o padrão de nome, escapando
# o '*' (file glob) que substitui qualquer conteúdo entre o nome padrão e
# a extensão '*.tgz':
DAYS7=$(find $BACKDIR -ctime 7 -name backup_home\*tgz)

# testando entre aspas duplas se há conteúdo na variável:
if [[ "$DAYS7" != 0 ]]
then
    echo "Backup is already created on \""$HOME"\" directory in last 7 days."
    # 'echo -n' para não quebrar a linha na entrada do dado:
    echo -n "Continue? (N/y): "
    # 'read -n1' para ler apenas o primeiro caractere digitado:
    read -n1 CONT
    # testando com || ('-o' or) se alguma alternativa de negação é válida;
    # note-se que a última alternativa tem conteúdo nulo, o que configura
    # o nulo como valor de significado padrão negativo, sinalizado para o
    # usuário com '-N' maiúsculo no 'echo -n' acima:
    if [[ "$CONT" = N || "$CONT" = n || "$CONT" = "" ]]
    then
        echo
        echo "Backup aborted!"
        # saída do script com erro #1:
        exit 1
    elif [[ "$CONT" = Y || "$CONT" = y ]]
    then
        echo
        echo "Another backup for the same week will be created."
    # exeption handling:
    else
        echo
        echo "Invalid option."
        # saída do script com erro #2:
        exit 2
    fi
fi

echo
echo "Backup is being created..."

# nome padrão do arquivo, com a insersão da data momento na inversão de comando:
BACKFILE="backup_home_$(date +%Y'-'%m'-'%d'-'%H':'%M).tgz"

# execução principal com redirecionamento final para '/dev/null', a fim de não
# exibir na tela saída do processo:
tar zcvpf $BACKDIR/$BACKFILE --absolute-names --exclude="$BACKDIR" "$HOME"/* > /dev/null

# comando de teste:
#tar zcvpf $BACKDIR/$BACKFILE --absolute-names --exclude="$HOME/.*" --exclude="$HOME/Downloads" --exclude="$BACKDIR" "$HOME"/* > /dev/null

echo
echo "Backup \""$BACKFILE"\" was created on \""$BACKDIR"\"."
echo
echo "Backup concluded successfully!"

