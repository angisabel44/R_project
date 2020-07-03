#!/bin/bash

BASEDEDATOS=imss

DIRECTORIO=modelos_svm_${BASEDEDATOS}/svm_0.00556
PARTICION=50
NUM=425
TIPO=aleatorio
COTA=10

gams svm.gms inputDir=${DIRECTORIO} output=${DIRECTORIO}/svm_${TIPO}_${PARTICION}.lst putDir=${DIRECTORIO} --p=${PARTICION} --n=${NUM} --C=${COTA} --nombre=${TIPO}