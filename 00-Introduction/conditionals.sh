#!/usr/bin/env bash

echo "Enter a number: #"
read number

if [[ $number -gt 10 ]]; then
    echo "The number is greater than 10."
elif [[ $number -lt 10 ]]; then
    echo "The number is lower than 10."
else
    echo "Invalid input."
fi
echo "------------------------------"
echo "Script Name: $0"
echo "Execution PID: $$"
