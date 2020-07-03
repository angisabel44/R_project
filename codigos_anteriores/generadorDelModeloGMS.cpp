#include <iostream>
#include <stdlib.h>
#include <fstream>
#include <iomanip>
#include <string>

using namespace std;

struct datos
{
	int numCoef;
	int numClases;
	float **coeficiente;
	int *clase;
};

datos *lectura(string _file);
void generadorDeModelo(string _file, datos *D, string C);

int main(int argc, char const *argv[])
{
	if (argc == 3)
	{
		datos *D = lectura(argv[1]);
		generadorDeModelo(argv[1], D, argv[2]);

		for (int i = 0; i < D->numCoef; ++i)
			delete [] D->coeficiente[i];
		delete [] D->coeficiente;
		delete [] D->clase;

		delete D;
	}
	else{cout << "Argumentos no enviados." << endl;}
	
	return 0;
}

datos *lectura(string _file){
	datos *D = new datos;

	string fileName = _file + "/coeficientes";
	string fileName2 = _file + "/clases";

	ifstream archivo(fileName.c_str());
	ifstream archivo2(fileName2.c_str());

	if (!archivo.is_open())
	{
		cout << "Archivo 1 no encontrado!!" << endl;
		exit(1);
	}

	if (!archivo2.is_open())
	{
		cout << "Archivo 2 no encontrado!!" << endl;
		exit(2);
	}

	int numCoef;
	archivo >> numCoef;

	float **m;

	m = new float *[numCoef];
	for (int i = 0; i < numCoef; ++i)
		m[i] = new float [numCoef];

	for (int i = 0; i < numCoef; ++i)
		for (int j = 0; j < numCoef; ++j)
			archivo >> m[i][j];

	archivo.close();

	int numClases;
	archivo2 >> numClases;

	int *c;

	c = new int [numClases];

	for (int i = 0; i < numClases; ++i)
		archivo2 >> c[i];

	archivo2.close();

	D->numCoef = numCoef;
	D->numClases = numClases;
	D->coeficiente = m;
	D->clase = c;

	return D;
}

void generadorDeModelo(string _file, datos *D, string C){
	int n = D->numCoef;
	int m = D->numClases;
	float **coeficiente = D->coeficiente;
	int *clase = D->clase;
	float c = atof(C.c_str());

	string salida = _file + "/SVM_" + C + ".gms";
	ofstream archivo(salida.c_str());

	archivo << "SETS" << endl;
	archivo << "\tI cantidad de caracteristicas / 1 * " << m << " /" << endl << endl;

	archivo << "ALIAS (i, j)" << endl << endl;

	archivo << "PARAMETERS" << endl;
	archivo << "\tY(i) clase a la que pertenece la caracteristica i" << endl;
	archivo << "\t\t/" << setw(4) << "1" << setw(3) << clase[0] << endl;

	for (int i = 1; i < m - 1; ++i)
		archivo << "\t\t" << setw(5) << i + 1 << setw(3) << clase[i] << endl;

	archivo << "\t\t" << setw(5) << m << setw(3) << clase[m - 1] << " /" << endl << endl;

	archivo << "TABLE K(i, j) matriz simetrica de coeficentes del kernel" << endl;
	archivo << "   ";
	for (int i = 0; i < n; ++i)
		archivo << setw(8) << i + 1;

	archivo << endl;

	for (int i = 0; i < n; ++i)
	{
		archivo << setw(3) << i + 1;
		for (int j = 0; j < n; ++j)
			archivo << setw(8) << coeficiente[i][j];
		archivo << endl;
	} archivo << endl;

	archivo << "VARIABLES" << endl;
	archivo << "\tA(i) las alphas" << endl;
	archivo << "\tFOBJ funcion objetivo" << endl << endl;

	archivo << "POSITIVE VARIABLE A" << endl << endl;

	archivo << "EQUATIONS" << endl;
	archivo << "\tOBJETIVO" << endl;
	archivo << "\tSA" << endl;
	archivo << "\tCOTAS(i);" << endl << endl;

	archivo << "OBJETIVO ..     FOBJ =E= SUM[i, A(i)] - (1/2) * SUM[(i, j), (A(i) * A(j) * Y(i) * Y(j) * K(i, j))];" << endl;
	archivo << "SA ..           SUM[i, A(i) * Y(i)] =E= 0;" << endl;
	archivo << "COTAS(i)..      A(i) =L= " << c << ";" << endl << endl;

	archivo << "MODEL SVM / OBJETIVO, SA, COTAS /" << endl << endl;
	archivo << "OPTION optcr = 0.0;" << endl << endl;
	archivo << "SOLVE SVM USING NLP MAXIMIZING FOBJ" << endl << endl;

	archivo << "FILE results / results /;" << endl;
	archivo << "results.pc = 4;" << endl;
	archivo << "PUT results;" << endl;
	archivo << "LOOP((i), PUT A.l(i) / );" << endl;
	archivo << "PUTCLOSE" << endl;

	archivo.close();
}