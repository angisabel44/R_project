#!/bin/bash

DIRECTORIO=$1*

for i in $DIRECTORIO
do
	echo $i
	rm -rf ${i}/neos_10_files
	rm -rf ${i}/neos_100_files
	rm -rf ${i}/neos_1000_files
done