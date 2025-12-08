#!/usr/bin/env bash

#################################################################
# create-file.sh                                                #
#                                                               #
# Site:         https://github.com/rulestux                     #
# Author:       Jean Felipe                                     #
# Maintenance:  Jean Felipe                                     #
#                                                               #
#################################################################
# This script reads input data and preserve it in a file with a #
# specified size.                                               #
#                                                               #
# Usage example:                                                #
#   ./create-file.sh                                            #
#                                                               #
#################################################################
# History:                                                      #
#   v1.0 2025-12-08, Jean Felipe.                               #
#                                                               #
#################################################################
# Tested on:                                                    #
#   zsh v5.9                                                    #
#                                                               #
#################################################################

# coletando informações sobre o arquivo e seu conteúdo:
read -p "Enter the file name: " FILE
read -p "Enter data to save: " WORD
read -p "Enter the final file size (in bytes): " SIZE

# tornando qualquer arquivo pré-existente, com o mesmo nome, um
# arquivo em branco com 'cat /dev/null':
cat /dev/null > $FILE

PERCENT_SHOW=0

# loop 'until' a ser realizado até que o tamanho do arquivo,
# obtido por 'stat --printf=%s', seja menor ou igual ao
# armazenado em $SIZE:
until [ $SIZE -le $(stat --printf=%s "$FILE") ]
do
    # inserindo o conteúdo de $WORD no arquivo, com 'echo -n'
    # para não haver quebra de linha:
    echo -n $WORD >> $FILE

    # obtento o tamanho do arquivo no instante do processo:
    INSTANT_SIZE=$(stat --printf=%s "$FILE")
    # obtendo a porcentagem atualmente obtida do tamanho final:
    INSTANT_PERC=$(expr $INSTANT_SIZE \* 100 / $SIZE)
    # lógica para obter porcentagens apenas de 10 em 10, a partir
    # do 'mod', com o resto da divisão: quando o resto da divisão
    # da porcentagem por dez for igual a zero, e a porcentagem
    # do exibida não for igual à atual...
    if [ $(expr $INSTANT_PERC % 10) -eq 0 -a $PERCENT_SHOW -ne $INSTANT_PERC ]
    then
        # exibir porcentagem:
        echo "Concluded: $INSTANT_PERC% - File size: $INSTANT_SIZE"
        PERCENT_SHOW=$INSTANT_PERC
    fi
done

