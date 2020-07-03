argv <- commandArgs(trailingOnly=TRUE)

directorio <- paste(argv[1], "/", sep = "")
C <- as.numeric(argv[2])

nombre <- paste(directorio, "gamma", sep = "")
g <- scan(file = nombre, what = double())

nombre <- paste(directorio, "particion", sep = "")
p <- scan(file = nombre, what = double())

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


nombre <- paste(directorio, "alphas_", C, sep = "")
alphas <- scan(file = nombre, what = double())

nombre <- paste(directorio, "entrenamiento", sep = "")
entrenamiento <- read.table(nombre, sep = " ", header = TRUE)

nombre <- paste(directorio, "prueba", sep = "")
prueba <- read.table(nombre, sep = " ", header = TRUE)

#Preparamos
A <- entrenamiento[,1:8]
B <- prueba[,1:8]
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
  
datos <- c(p, g, C, as.vector(matrizConf$table), matrizConf$overall, matrizConf$byClass)

#prediccion <- as.numeric(resultados > 0)
#prediccion[prediccion == 0] <- -1
#cantidadDePredicciones <- table(prediccion == prueba$diabetes)
#presicion <- as.numeric(cantidadDePredicciones[2] / sum(cantidadDePredicciones))

cat(datos, file = "resultados", eol = "\n", sep = " ", append = TRUE)
