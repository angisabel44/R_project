#!/bin/bash

BASEDEDATOS=pid

PROB=(50 60 70 75 80)
NUM=(384 460 537 576 614)
COTA=10

DIRECTORIO=modelos_svm_${BASEDEDATOS}/*

rm -rf dondevaelgams.txt

for i in $DIRECTORIO
do
	echo $i >> dondevaelgams.txt
	for j in 0 1 2 3 4
	do
		for k in aleatorio balanceado
		do
			echo -e "\t${BASEDEDATOS} svm_${k}_${PROB[j]}.lst ${COTA}" >> dondevaelgams.txt
			#echo gams svm.gms inputDir=$i output=${i}/svm_${k}_${PROB[j]}.lst putDir=$i --p=${PROB[j]} --n=${NUM[j]} --C=${COTA} --nombre=${k}
			gams svm.gms inputDir=$i output=${i}/svm_${k}_${PROB[j]}.lst putDir=$i --p=${PROB[j]} --n=${NUM[j]} --C=${COTA} --nombre=${k}
		done
	done
done

rm -rf dondevaelgams.txt