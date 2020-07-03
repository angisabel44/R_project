#include <iostream>
#include <stdlib.h>
#include <fstream>
#include <iomanip>
#include <string>

using namespace std;

struct datos
{
	int dim;
	float *alpha;
};

datos *lecturaDeLasAlphas(string _file1, string _file2);
void imprimirAlphas(string _file1, datos *alpha, string _file2);

int main(int argc, char const *argv[])
{
	if (argc == 3)
	{
		datos *alphas = lecturaDeLasAlphas(argv[1], argv[2]);
		imprimirAlphas(argv[1], alphas, argv[2]);

		delete [] alphas->alpha;
		delete alphas;
	}
	else{cout << "Argumento no enviados." << endl;}
	
	return 0;
}

datos *lecturaDeLasAlphas(string _file1, string _file2)
{
	string fileName = _file1 + "/neos_" + _file2 + ".html";
	ifstream archivo(fileName.c_str());
	string aux;

	if (!archivo.is_open())
	{
		cout << "Archivo 1 no encontrado!!" << endl;
		exit(1);
	}

	do
	{
		archivo >> aux;
	} while (aux != "N-Z" || archivo.eof());

	if (archivo.eof())
	{
		cout << "Solucion no se encuentra." << endl;
		exit(2);
	}

	int numAlphas;
	archivo >> numAlphas;

	float *alpha;
	alpha = new float [numAlphas];

	do
	{
		archivo >> aux;
	} while (aux != "alphas");

	for (int i = 0; i < 4; ++i)
		archivo >> aux;

	for (int i = 0; i < numAlphas; ++i)
	{
		for (int j = 0; j < 2; ++j)
			archivo >> aux;

		archivo >> aux;
		if (aux == ".")
			alpha[i] = 0;
		else
			alpha[i] = atof(aux.c_str());

		for (int j = 0; j < 2; ++j)
			archivo >> aux;
	}

	archivo.close();

	datos *alphas = new datos;

	alphas->dim = numAlphas;
	alphas->alpha = alpha;

	return alphas;
}

void imprimirAlphas(string _file1, datos *alphas, string _file2)
{
	int dim = alphas->dim;
	float *alpha = alphas->alpha;

	string fileName = _file1 + "/alphas_" + _file2;
	ofstream archivo(fileName.c_str());

	for (int i = 0; i < dim; ++i)
		archivo << alpha[i] << " ";

	archivo.close();
}