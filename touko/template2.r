library(MASS)
library(rgl)

test<-as.dist(read.csv("temp4.csv",header=F,skip=1))
test.iso<-isoMDS(test,k=3)
plot3d(test.iso$points,xlab="X",ylab="Y",zlab="Z",type="n")
plot3d(test.iso$points,add=T,type="n")
text3d(test.iso$points,texts=rownames(test.iso$points))

