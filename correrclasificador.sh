#!/bin/bash

BASEDEDATOS=pid
COTA=10

DIRECTORIO=modelos_svm_${BASEDEDATOS}/*

rm -rf dondevaelclasificador.txt

for i in $DIRECTORIO
do
	echo $i >> dondevaelclasificador.txt
	for j in 50 60 70 75 80
	do
		for k in aleatorio balanceado
		do
			echo -e "\t$j $k ${COTA} ${BASEDEDATOS}" >> dondevaelclasificador.txt
			Rscript clasificador.R $i $j $k ${COTA} ${BASEDEDATOS}
		done
	done
	#rm -rf combinacion.txt
done

rm -rf dondevaelclasificador.txt