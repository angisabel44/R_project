#Porcentage de entrenamiento
argv <- commandArgs(trailingOnly=TRUE)
p <- as.numeric(argv[1])

#Libreria donde esta la base datos PimaIndiansDiabetes
suppressMessages(library(mlbench))
data("PimaIndiansDiabetes2") #Se llama a la base de datos

#Hacemos las clases numericas
PimaIndiansDiabetes2$diabetes <- as.numeric(PimaIndiansDiabetes2$diabetes)
PimaIndiansDiabetes2$diabetes[PimaIndiansDiabetes2$diabetes == 1] <- -1
PimaIndiansDiabetes2$diabetes[PimaIndiansDiabetes2$diabetes == 2] <- 1

sanas <- PimaIndiansDiabetes2[PimaIndiansDiabetes2$diabetes == -1,]
enfermas <- PimaIndiansDiabetes2[PimaIndiansDiabetes2$diabetes == 1,]

#Para saber la cantdad de Na's en la base de datos
cantidad <- sapply(sanas, function(x) sum(is.na(x)))

#Se rellenan los Na's con las medias redondeada
columnas <- ncol(sanas) - 1
for(i in 1:columnas){
  if (cantidad[i] != 0) {
    sanas[is.na(sanas[,i]), i] <- round(
      mean(sanas[,i], na.rm = TRUE))
  }
}

#Para saber la cantdad de Na's en la base de datos
cantidad <- sapply(enfermas, function(x) sum(is.na(x)))

#Se rellenan los Na's con las medias redondeada
columnas <- ncol(enfermas) - 1
for(i in 1:columnas){
  if (cantidad[i] != 0) {
    enfermas[is.na(enfermas[,i]), i] <- round(
      mean(enfermas[,i], na.rm = TRUE))
  }
}

PimaIndiansDiabetes2 <- rbind(sanas, enfermas)
rm(sanas, enfermas)

#Preparamos las bases de datos
cantidad <- nrow(PimaIndiansDiabetes2)
n <- floor(cantidad * p)
set.seed(1)
muestra <- sample(cantidad, n)

entrenamiento <- PimaIndiansDiabetes2[muestra,]
prueba <- PimaIndiansDiabetes2[-muestra,]

pidpositivos <- PimaIndiansDiabetes2[PimaIndiansDiabetes2$diabetes == 1,]
pidnegativos <- PimaIndiansDiabetes2[PimaIndiansDiabetes2$diabetes == -1,]

cantidadpositivos <- nrow(pidpositivos)
cantidadnegativos <- nrow(pidnegativos)
npositivos <- floor(cantidadpositivos * p)
nnegativos <- floor(cantidadnegativos * p)
set.seed(2)
muestrapositivos <- sample(cantidadpositivos, npositivos)
muestranegativos <- sample(cantidadnegativos, nnegativos)
entrenamientopositivos <- pidpositivos[muestrapositivos,]
entrenamientonegativos <- pidnegativos[muestranegativos,]
pruebapositivos <- pidpositivos[-muestrapositivos,]
pruebanegativos <- pidnegativos[-muestranegativos,]

entrenamientobalanceado <- rbind(entrenamientopositivos, entrenamientonegativos)
pruebabalanceada <- rbind(pruebapositivos, pruebanegativos)

directorio <- "bases_de_datos/"
if (!dir.exists(directorio)) {
  dir.create(directorio)
}

nombre <- paste(directorio, "pid_entrenamiento_aleatorio_", p * 100, ".txt", sep = "")
write.table(entrenamiento, file = nombre, row.names = FALSE)
nombre <- paste(directorio, "pid_prueba_aleatorio_", p * 100, ".txt", sep = "")
write.table(prueba, file = nombre, row.names = FALSE)

nombre <- paste(directorio, "pid_entrenamiento_balanceado_", p * 100, ".txt", sep = "")
write.table(entrenamientobalanceado, file = nombre, row.names = FALSE)
nombre <- paste(directorio, "pid_prueba_balanceado_", p * 100, ".txt", sep = "")
write.table(pruebabalanceada, file = nombre, row.names = FALSE)

nombre <- paste(directorio, "pid_n_aleatorio_", p * 100, ".txt", sep = "")
cat(paste("n = ", nrow(entrenamiento), "\np = ", 100 * p), file = nombre)

nombre <- paste(directorio, "pid_n_balanceado_", p * 100, ".txt", sep = "")
cat(paste("n = ", nrow(entrenamientobalanceado), "\np = ", 100 * p), file = nombre)