#!/bin/bash

DIRECTORIO=coeficientes/*

for i in $DIRECTORIO
do
	for j in 10 100 1000
	do
		echo exportarAlphas $i $j
		./exportarAlphas $i $j
	done
done

for i in $DIRECTORIO
do
	for j in 10 100 1000
	do
		echo RSCRIPT clasificadorBeta.R $i $j
		Rscript clasificadorbeta.R $i $j
	done
done