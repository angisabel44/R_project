SETS
	I cantidad de caracteristicas / 1 * %n% /

ALIAS (i, j)

PARAMETERS Y(i) clase a la que pertenece la caracteristica i /
$ondelim
$include clases_%nombre%_%p%.csv
$offdelim
/;

TABLE K(i, j) matriz simetrica de coeficentes del kernel
$ondelim
$include coeficientes_%nombre%_%p%.csv
$offdelim
;

VARIABLES
	A(i) las alphas
	FOBJ funcion objetivo

POSITIVE VARIABLE A

EQUATIONS
	OBJETIVO
	SA
	COTAS(i);

OBJETIVO ..     FOBJ =E= SUM[i, A(i)] - (1/2) * SUM[(i, j), (A(i) * A(j) * Y(i) * Y(j) * K(i, j))];
SA ..           SUM[i, A(i) * Y(i)] =E= 0;
COTAS(i)..      A(i) =L= %C%;

MODEL SVM / OBJETIVO, SA, COTAS /;

SVM.optfile = 1;
OPTION NLP = kestrel;
OPTION optcr = 0.0;

SOLVE SVM USING NLP MAXIMIZING FOBJ;
$echo kestrel_solver CONOPT > kestrel.opt

FILE results / alphas_%nombre%_%p%.txt /;
results.pc = 4;
results.nd = 10;
PUT results;
LOOP((i), PUT A.l(i) / );
PUTCLOSE