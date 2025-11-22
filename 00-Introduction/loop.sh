#!/usr/bin/env bash

echo "======== FOR ========"

# sintaxe do 'for' no shell:
for (( i = 0; i < 10; i++ ))
do
    echo $i
done

echo "======== FOR (seq) ========"

for i in $(seq 10)
do
    echo $i
done

echo "======== FOR (array) ========"

fruits=(
'Orange'
'Plum'
'Pineapple'
'whatermelon'
)

# para chamar o array (vetor) usam-se chaves;
# para evocar todas as posições do array, usa-se @;
# para garantir a formatação de uma string, incluso
# quebras de linhas, usam-se as aspas:
for i in "${fruits[@]}"
do
    echo "$i"
done

echo "======== WHILE ========"

counter=0

while [[ $counter -lt ${#fruits[@]} ]]
do
    counter=$(( $counter+1 ))   # o mesmo que $counter++
    echo $counter
done

echo "======== EXERCISE ========"

# linhas de código bash para mostrar quais números
# de um a dez são divisíveis por dois:
for i in $(seq 1 10)
do
    [[ $(($i % 2)) -eq 0 ]] && echo "#$i is divisible by two"
done
