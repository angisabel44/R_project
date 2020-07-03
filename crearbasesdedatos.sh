#!/bin/bash

#DIRECTORIO=coeficientes/*
BASEDEDATOS=pid

for i in 0.5 0.6 0.7 0.75 0.8
do
	echo Rscript datos_particionados_${BASEDEDATOS}.R $i
	Rscript datos_particionados_${BASEDEDATOS}.R $i
done

for i in 0.5 0.6 0.7 0.75 0.8
do
	for j in aleatorio balanceado
	do
		echo Rscript coeficientes_del_modelo.R $i $BASEDEDATOS $j
		Rscript coeficientes_del_modelo.R $i $BASEDEDATOS $j
	done
done