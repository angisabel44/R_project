#Porcentage de entrenamiento
p <- commandArgs(trailingOnly=TRUE)
p <- as.numeric(p[1])

#Funcion kernel gaussiana
gammas <- seq(0.00001, 0.01, length.out = 10)
#gammas <- sort(c(10^(-7:2), 2^(-6:-1), 2^(1:6)))

#Presicion de los digitos
presicion <- 4

k <- function(i, j, g){
  x <- i - j
  norma <- sum(x * x)
  exponete <- -g * norma
  return(exp(exponete))
}

#Funcion para calcular coeficientes que se va a paralelizar
fcoeficientes <- function(j){
  x1 <- A[i,]
  x2 <- A[j,]
  if (i == j) {
    numero <- y[i] * y[j]
  } else {
    #numero <- 2 * y[i] * y[j] * k(x1, x2, g)
    numero <- y[i] * y[j] * k(x1, x2, g)
  }
  return(numero)
}

#Libreria donde esta la base datos PimaIndiansDiabetes
suppressMessages(library(mlbench))
data("PimaIndiansDiabetes2") #Se llama a la base de datos

#Para saber la cantdad de Na's en la base de datos
cantidad <- sapply(PimaIndiansDiabetes2, function(x) sum(is.na(x)))

#Se rellenan los Na's con las medias redondeada
columnas <- ncol(PimaIndiansDiabetes2) - 1
for(i in 1:columnas){
  if (cantidad[i] != 0) {
    PimaIndiansDiabetes2[is.na(PimaIndiansDiabetes2[,i]), i] <- round(
      mean(PimaIndiansDiabetes2[,i], na.rm = TRUE))
  }
}

#Hacemos las clases numericas
PimaIndiansDiabetes2$diabetes <- as.numeric(PimaIndiansDiabetes2$diabetes)
PimaIndiansDiabetes2$diabetes[PimaIndiansDiabetes2$diabetes == 1] <- -1
PimaIndiansDiabetes2$diabetes[PimaIndiansDiabetes2$diabetes == 2] <- 1

#Preparamos las bases de datos
cantidad <- dim(PimaIndiansDiabetes2)[1]
n <- floor(cantidad * p)
set.seed(1)
muestra <- sample(cantidad, n)
entrenamiento <- PimaIndiansDiabetes2[muestra,]
prueba <- PimaIndiansDiabetes2[-muestra,]

A <- entrenamiento[,1:8]
y <- entrenamiento$diabetes

suppressMessages(library(parallel))
cluster <- makeCluster(detectCores() - 1)
clusterExport(cluster,  c("A", "y", "k"))

datos <- double()
tiempos <- numeric()

filas <- nrow(A)
for (l in 1:length(gammas)) {
  coeficientes <- double()
  g <- gammas[l]
  print(paste("Gamma:", g))
  clusterExport(cluster, "g")
  t <- round(as.numeric(system.time({
    for (i in 1:filas) {
      clusterExport(cluster, "i")
      resultados <- parSapply(cluster, i:filas, fcoeficientes)
      coeficientes <- c(coeficientes, round(resultados, digits = presicion))
    }
  })[3]))
  tiempos <- c(tiempos, t)
  datos <- cbind(datos, coeficientes)
  
  C <- matrix(0, ncol = filas, nrow = filas)
  C[lower.tri(C, diag = TRUE)] <- coeficientes
  C <- t(C)
  C[lower.tri(C)] <- t(C)[lower.tri(C)]
  
  directorio <- paste("coeficientes/coeficientes", g, "_", p, "/", sep = "")
  if (!dir.exists(directorio)) {
    dir.create(directorio)
  }
  
  nombre <- paste(directorio, "gamma", sep = "")
  cat(g, file = nombre)
  
  nombre <- paste(directorio, "particion", sep = "")
  cat(p, file = nombre)
  
  nombre <- paste(directorio, "coeficientes", sep = "")
  cat(dim(C)[1], file = nombre, eol = "\n")
  write.table(C, file = nombre, row.names = FALSE, col.names = FALSE, append = TRUE)
  
  nombre <- paste(directorio, "clases", sep = "")
  cat(c(length(y), y), file = nombre, sep = " ")
  
  nombre <- paste(directorio, "entrenamiento", sep = "")
  write.table(entrenamiento, file = nombre, row.names = FALSE)
  
  nombre <- paste(directorio, "prueba", sep = "")
  write.table(prueba, file = nombre, row.names = FALSE)
}
stopCluster(cluster)

nombre <- paste("tiempos_", p)
cat(tiempos, file = nombre, sep = " ")

nombre <- paste("gammas_", p, ".pdf")
pdf(nombre, width = 10, height = 6)
boxplot(datos, xlab="Gammas", ylab="Valores de los coeficientes", 
        names = gammas, las = 2)
dev.off()
