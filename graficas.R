basededatos <- "pid"

nombre <- paste(basededatos, "/resultados_", basededatos, ".txt", sep = "")
resultados <- read.table(nombre, quote="\"", comment.char="")

nombres <- c("Gamma", "Particion", "Tipo", "C", "TN", "FP", "FN", "TP",
             "Exactitud", "Kappa", "AccuracyLower", "AccuracyUpper", "AccuracyNull", "AccuracyPValue", "McnemarPValue",
             "Sensibilidad", "Especificidad", "PosPred", "NegPred", "Presicion", "Recall", "F1",
             "Prevalance", "DetectionRate", "DetectionPrevalence", "BalancedAcc")
names(resultados) <- nombres

resultados <- resultados[order(resultados$Gamma),]
#resultados <- resultados[order(resultados$Exactitud),]

require(ggplot2)
require(gridExtra)

ggplot(data = resultados, aes(x = as.factor(Gamma), y = Exactitud, 
                              group = Particion, color = as.factor(Particion))) +
  facet_wrap(~Tipo, ncol = 1) + geom_point() + geom_line() +
  theme(axis.text.x =element_text(angle = 90)) + xlab("Gamma") + labs(color = "Partición")

ggplot(data = resultados, aes(x = as.factor(Gamma), y = Sensibilidad, 
                              group = Particion, color = as.factor(Particion))) +
  facet_wrap(~Tipo, ncol = 1) + geom_point() + geom_line() +
  theme(axis.text.x =element_text(angle = 90)) + xlab("Gamma") + labs(color = "Partición")

ggplot(data = resultados, aes(x = as.factor(Gamma), y = Especificidad, 
                              group = Particion, color = as.factor(Particion))) +
  facet_wrap(~Tipo, ncol = 1) + geom_point() + geom_line() +
  theme(axis.text.x =element_text(angle = 90)) + + xlab("Gamma") + labs(color = "Partición")

ggplot(data = resultados, aes(x = as.factor(Gamma), y = F1, 
                              group = Particion, color = as.factor(Particion))) +
  facet_wrap(~Tipo, ncol = 1) + geom_point() + geom_line() +
  theme(axis.text.x =element_text(angle = 90))

datos <- resultados[resultados$C == 10,]

g1 <- ggplot(data = datos, aes(x = as.factor(Gamma), y = Exactitud, 
                              group = Particion, color = as.factor(Particion))) +
  geom_point() + geom_line() +
  theme(axis.text.x =element_text(angle = 90)) + labs(color = "Partición") +
  xlab("Gammas") + ylab("Exactitud")

g2 <- ggplot(data = datos, aes(x = as.factor(Gamma), y = Sensibilidad, 
                         group = Particion, color = as.factor(Particion))) +
  geom_point() + geom_line() +
  theme(axis.text.x =element_text(angle = 90)) + labs(color = "Partición") +
  xlab("Gammas") + ylab("Sensibilidad")

g3 <- ggplot(data = datos, aes(x = as.factor(Gamma), y = Especificidad, 
                         group = Particion, color = as.factor(Particion))) +
  geom_point() + geom_line() + theme(axis.text.x =element_text(angle = 90)) + 
  labs(color = "Partición") + xlab("Gammas") + ylab("Especificidad")

grid.arrange(g1, g2, g3, nrow = 3)

gammas <- seq(0.00001, 0.01, length.out = 10)

datos <- data.frame()
for (g in gammas) {
  carpeta <- paste("modelos_svm_", basededatos, "/svm_", g, "/", sep = "")
  for (p in c(50, 60, 70, 75, 80)) {
    for (t in c("aleatorio", "balanceado")) {
      archivo <- paste(carpeta, "alphas_", t, "_", p, ".txt", sep = "")
      alphas <- scan(file = archivo, what = double())
      n <- length(alphas)
      datos <- rbind(datos, cbind(rep(g, n), rep(p, n), rep(t, n), alphas))
    }
  }
}
names(datos) <- c("gamma", "particion", "tipo", "alphas")

ggplot(data = datos, aes(x = as.factor(gamma), y = alphas, color = particion)) +
  geom_boxplot() + facet_wrap(~tipo, ncol = 1)
