#Porcentage de entrenamiento
argv <- commandArgs(trailingOnly=TRUE)

p <- as.numeric(argv[1])
basededatos <- paste("bases_de_datos/", argv[2] ,"_entrenamiento_", argv[3], "_", p * 100, ".txt", sep = "")

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

entrenamiento <- read.table(basededatos, sep = " ", header = TRUE)

columnas <- ncol(entrenamiento) - 1
A <- entrenamiento[,1:columnas]
y <- entrenamiento$diabetes

datos <- double()
tiempos <- numeric()
filas <- nrow(A)

suppressMessages(library(parallel))
cluster <- makeCluster(detectCores() - 1)
clusterExport(cluster,  c("A", "y", "k"))

for (g in gammas) {
  coeficientes <- double()
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
  colnames(C) <- 1:filas
  
  if (!dir.exists(paste("modelos_svm_", argv[2], "/", sep = ""))) {
    dir.create(paste("modelos_svm_", argv[2], "/", sep = ""))
  }
  
  directorio <- paste("modelos_svm_", argv[2], "/svm_", g, "/", sep = "")
  if (!dir.exists(directorio)) {
    dir.create(directorio)
  }
  
  nombre <- paste(directorio, "gamma.txt", sep = "")
  cat(g, file = nombre)
  
  nombre <- paste(directorio, "coeficientes_", argv[3], "_", p * 100, ".csv", sep = "")
  cat(",", file = nombre, eol = "")
  write.table(C, file = nombre, row.names = TRUE, col.names = TRUE, sep = ",", append = TRUE)
  
  nombre <- paste(directorio, "clases_", argv[3], "_", p * 100, ".csv", sep = "")
  write.table(y, file = nombre, col.names = FALSE, sep = ", ")
}
stopCluster(cluster)

if (!dir.exists(paste(argv[2], "/", sep = ""))) {
  dir.create(paste(argv[2], "/", sep = ""))
}

nombre <- paste(argv[2], "/tiempos_", p * 100, ".txt", sep = "")
cat(tiempos, file = nombre, sep = " ")

nombre <- paste(argv[2], "/gammas_", p * 100, ".pdf", sep = "")
pdf(nombre, width = 10, height = 6)
boxplot(datos, xlab="Gammas", ylab="Valores de los coeficientes", 
        names = gammas, las = 2)
dev.off()