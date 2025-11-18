#!/usr/bin/env bash

#################################################################
# machine-report.sh - output PC data.                           #
#                                                               #
# Site:         https://github.com/rulestux                     #
# Author:       Jean Felipe                                     #
# Maintenance:  Jean Felipe                                     #
#                                                               #
#################################################################
# This script reads and outputs system files in order to show   #
# system informations.                                          #
#                                                               #
# Usage example:                                                #
#   ./machine-report.sh                                         #
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

# para obter os dados do Kernel, usou-se substituição de comando,
# na variável, como nos casos a seguir, mas com o comando
# 'uname -r':
KERNEL=$(uname -r)
HOSTNAME=$(hostname)
# para obter o número de  CPUs, filtram-se com 'grep' as linhas
# retornadas pelo 'cat' de '/proc/cpuinfo', as quais são contadas
# com 'wc -l':
CPUN=$(cat /proc/cpuinfo | grep "model name" | wc -l)
# com o mesmo filtro acima, pode-se obter com 'head -n1' a primeira
# linha de cada resultado e, com 'cut -c14-', removem-se as
# primeiras 14 colunas (posições) de cada linha:
CPUMODEL=$(cat /proc/cpuinfo | grep "model name" | head -n1 | cut -c14-)
# de '/proc/meminfo' obtém-se a memória total numa busca com 'grep'
# pela linha que contém 'MemTotal', da qual o comando 'tr -d ' ''
# (translate or delete) deleta os espaços e o comando 'cut -d: -f2',
# para separar os campos com a opção '-d', usando ':' como critério
# de divisão, e exibir somente o segundo campo com a opção '-d2',
# removendo aind o 'kB' com 'tr -d'; o resultado então é dividido
# por 1024 para se obter a quantidade de memória em megabytes:
TOTALMEM=$(expr $(cat /proc/meminfo | grep MemTotal | tr -d ' ' | cut -d: -f2 | tr -d kB ) / 1024)
# para obter o filesystem, usa-se 'df -h', que retorna dados
# organizados do uso do armazenamento, dos quais se removem com
# 'egrep -v' tudo o que contiver 'tmpfs' ou 'udev' com a sintaxe
# '(tmpfs | udev)', na qual o pipe é interpretado como operador
# lógico:
FILESYS=$(df -h | egrep -v '(tmpfs | udev)')
# tempo de uso do sistema desde o último boot:
UPTIME=$(uptime -s)

clear
echo "══════════════════════════════════════════════"
echo " Machine Report of $HOSTNAME"
echo " Date/Hour: $(date)"
echo " Machine on since: $UPTIME"
echo " Kernel version: $KERNEL"
echo "──────────────────────────────────────────────"
echo " CPU data:"
echo " CPU cores: $CPUN"
echo " CPU model: $CPUMODEL"
echo "──────────────────────────────────────────────"
echo " Total memory: $TOTALMEM MB"
echo "──────────────────────────────────────────────"
echo " Partitions:"
echo " $FILESYS"
echo "══════════════════════════════════════════════"
