#!/usr/bin/env bash

# sintaxe da condicional reduzida:
# [ <elemento> <operador> <elemento> ] && <comando>
# usando condicional reduzida para imprimir
# o resultado somente se o parâmetro inserido
# na chamada do script for maior que 10:
[[ $1 -gt 10 ]] && echo "Script Name: $0 | Execution PID: $$"
