#!/bin/bash

DIRECTORIO=ExperimentacionBeta/coeficientes/*

for i in $DIRECTORIO
do
	for j in 10
	do
		echo RSCRIPT clasificadorBeta.R $i $j
		Rscript clasificadorbeta.R $i $j
	done
done
