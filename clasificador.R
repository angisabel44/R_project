argv <- commandArgs(trailingOnly=TRUE)

directorio <- paste(argv[1], "/", sep = "")
dirbasesdedatos <- paste("bases_de_datos/", argv[5], "_", sep = "")

p <- as.numeric(argv[2])
tipo <- argv[3]
C <- as.numeric(argv[4])

nombre <- paste(directorio, "gamma.txt", sep = "")
g <- scan(file = nombre, what = double())

nombre <- paste(directorio, "alphas_", tipo, "_", p, ".txt", sep = "")
alphas <- scan(file = nombre, what = double())

nombre <- paste(dirbasesdedatos, "entrenamiento_", tipo, "_", p, ".txt", sep = "")
entrenamiento <- read.table(nombre, sep = " ", header = TRUE)

nombre <- paste(dirbasesdedatos, "prueba_", tipo, "_", p, ".txt", sep = "")
prueba <- read.table(nombre, sep = " ", header = TRUE)

k <- function(i, j, g){
  x <- i - j
  norma <- sum(x * x)
  exponete <- -g * norma
  return(exp(exponete))
}

clasificador <- function(j){
  H <- 0
  x <- B[j,]
  for (i in which(alphas > 0)) {
    xi <- A[i,]
    H <- H + alphas[i] * y[i] * k(x, xi, g)
  }
  H <- H + b
  return(H)
}

intersecciones <- function(i){
  indices <- which(alphas > 0)
  alphasy  <- alphas[indices] * y[indices]
  w <- double()
  for (j in indices) {
    #productopunto <- sum(A[j,] * A[i,])
    productopunto <- k(A[j,], A[i,], g)
    w <- c(w, productopunto)
  }
  q <- y[i] - sum(alphasy * w)
  return(q)
}

#Preparamos
columnas <- ncol(entrenamiento) - 1
A <- entrenamiento[,1:columnas]
B <- prueba[,1:columnas]
y <- entrenamiento$diabetes

suppressMessages(library(parallel))
cluster <- makeCluster(detectCores() - 1)
clusterExport(cluster,  c("g", "B", "A", "y", "k", "alphas"))

bs <- parSapply(cluster, which(alphas > 0), intersecciones)
b <- mean(bs)

clusterExport(cluster, "b")
filas <- nrow(prueba)
resultados <- parSapply(cluster, 1:filas, clasificador)
stopCluster(cluster)

if (anyNA(resultados)) {
  resultados[is.na(resultados)] <- 1
}

resultados[resultados >= 0] <-  1
resultados[resultados < 0] <- -1

suppressMessages(library(caret))
y <- prueba$diabetes
matrizConf <- confusionMatrix(data = as.factor(resultados),
                              reference = as.factor(y), positive = "1")

datos <- c(g, p, tipo, C, as.vector(matrizConf$table), matrizConf$overall, matrizConf$byClass)

#prediccion <- as.numeric(resultados > 0)
#prediccion[prediccion == 0] <- -1
#cantidadDePredicciones <- table(prediccion == prueba$diabetes)
#presicion <- as.numeric(cantidadDePredicciones[2] / sum(cantidadDePredicciones))

nombre <- paste(argv[5], "/resultados_", argv[5], ".txt", sep = "")
cat(datos, file = nombre, eol = "\n", sep = " ", append = TRUE)
