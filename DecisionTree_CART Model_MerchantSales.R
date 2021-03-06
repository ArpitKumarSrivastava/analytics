# CART Models - Regression Trees - Merchent Sales
#Predict the mean sales from the data; create decision tree
library(rpart)  # CART algo
library(rpart.plot)# visualising decision tree
library(forecast)# calculating accuracy





getwd()
setwd("D:/R Training/Training/Decision Tree/")
install.packages("RCurl")
install.packages("foreign")
library(RCurl)
library(foreign)

"url <- "https://raw.githubusercontent.com/dupadhyaya/hhanalytics/master/DATA/msales.csv"

disproportionality.data <- getURL(url)                

disproportionality.data <- read.csv(textConnection(disproportionality.data))"



msales = read.csv(text= getURL("https://raw.githubusercontent.com/dupadhyaya/hhanalytics/master/DATA/msales.csv") 
                  ,skip = 1, header = T)
dim(msales)

write.csv(msales,file = "C:/Users/ekratsh/Desktop/Training/Day 3/Decision Tree/msales.csv")
# Summarize the dataset
summary(msales)
str(msales)
# See Summary values of sales
aggregate(msales$sales,by=list(msales$zone), FUN = mean)

# Random Sampling : Train and Test
set.seed(777) # To ensure reproducibility

Index = sample(1:nrow(msales), size = 0.80*nrow(msales))

Index
length(Index)

par(mfrow= c(1,2))

#divide data into 2 parts - Train (70%), Test(30%)

# Create Train dataset

train = msales[Index, ]
nrow(train); dim(train)

# Create Test dataset
test = msales[-Index, ]
nrow(test); dim(test)

#### Modeling ############
# Build a full model with default settings
set.seed(123)

CartModel=rpart(sales ~ . ,data=train[,-1], method="anova")


CartModel
summary(CartModel)

# Plot the Regression Tree
rpart.plot(CartModel,type=1,fallen.leaves=T,nn=T, cex=1)
mean(msales$sales)
printcp(CartModel)
rsq.rpart(CartModel)  #only for Regression Tree

prune1 = prune(CartModel, cp=.025)
prune1
rpart.plot(prune1, nn=T, cex=1, type=4)

#### Using CP to expand / Prune the tree ###
#Start fresh Model
RpartControl = rpart.control(cp = 0.005)
set.seed(123)
CartModel_1 = rpart(sales ~ ., data = msales[,-1], 
                    method = "anova", control = RpartControl)
CartModel_1
rpart.plot(CartModel_1, nn=T, cex=1)
CartModel_1$where
msales[987,'sales']
CartModel_1$frame
trainingnodes = rownames(CartModel_1$frame) [ CartModel_1$where]
trainingnodes

summary(CartModel_1)
rpart.plot(CartModel_1, type = 4,cex = 0.6)
printcp(CartModel_1)
rsq.rpart(CartModel_1)




#Validation / Test Accuracy
PredictTest=predict(CartModel,newdata=test,type="vector")

PredictTest1 <- predict(prune1,newdata=test,type="vector")

#PredictTest1=predict(CartModel_1,newdata=test,type="vector")
#PredictTest1
#length(PredictTest)
#msales[2,'sales']

test_pred <-  cbind(test$sales, PredictTest,
                    PredictTest1)

# Calculate RMSE and MAPE 
library(forecast)
# Validate RMSE and MAPE calculation with a function in R
length(train$sales)
ModelAccuracy = accuracy(PredictTest,test$sales)
ModelAccuracy1 = accuracy(PredictTest1,test$sales)
rbind(ModelAccuracy,ModelAccuracy1)

#select model with least error
