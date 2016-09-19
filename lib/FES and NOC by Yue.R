load("/Users/wangyue/Desktop/data.RData")
# library used
install.packages("circlize")
install.packages("googleVis")
library(sqldf)
library(dplyr)
library(ggplot2)
library(plotly)
library(googleVis)
# EDA of NOC
summary(df$NOC)
boxplot(df$NOC)
# study the relationship bt FES and NOC
working <- select(df, NOC, FES)
work1 <- working %>%
          na.omit()
size <- count(work1, FES)
# compare mean of different FES
result <- aggregate(NOC~FES, data = work1, FUN=mean)
# bubble chart
d <- diamonds[sample(nrow(diamonds),1000),]
plot_ly(d,x=result$FES, y=result$NOC, size=size$n, mode="markers") %>%
  layout(title = "Bubble chart of FES and mean of NOC", xaxis = list(title = "FES"), yaxis = list(title = "NOC"))
# FamilyTypeEmploymentStatus code
fescode <- "FES,FamilyTypeEmploymentStatus
1, Both in Labor Force
2, Only Husband in Labor Force
3, Only Wife in Labor Force
4, Neither in Labor Force
5, Male in Labor Force
6, Male not in Labor Force
7, Female in Labor Force
8, Female not in Labor Force
"
codeoffes <- fread(fescode)
work1 = tbl_df(work1)
# work2 is the table group_by(NOC,FES)
work2 <- work1 %>% group_by(NOC,FES) %>% summarise(n=n()) %>% mutate(percentage = n/sum(n) * 100)
work2 <- mutate(work2, percentage = round(percentage,2))
work2 <- sqldf('SELECT work2.NOC, work2.FES,work2.n,work2.percentage, codeoffes.FamilyTypeEmploymentStatus from work2,codeoffes where work2.FES=codeoffes.FES')
# by percentage
ggplot(work2,aes(x=NOC,y=percentage,fill=factor(FamilyTypeEmploymentStatus)))+xlab("Number of children")+ylab("Percentage")+geom_bar(stat="identity")+ggtitle("Percentage of FES under different NOC")
# by number
ggplot(work2,aes(x=NOC,y=n,fill=factor(FamilyTypeEmploymentStatus)))+xlab("Number of children")+ylab("Total Number")+geom_bar(stat="identity")+ggtitle("Total Number of FES under different NOC")
# work3 is the table group_by(FES,NOC)
work3 <- work1 %>% group_by(FES,NOC) %>% summarise(n=n()) %>% mutate(percentage = n/sum(n) * 100)
work3 <- mutate(work3,percentage = round(percentage,2))
work3 <- sqldf('SELECT work3.FES, work3.NOC,work3.n,work3.percentage, codeoffes.FamilyTypeEmploymentStatus from work3,codeoffes where work3.FES=codeoffes.FES')
# by percentage 
ggplot(work3,aes(x=FES,y=percentage,fill=factor(NOC)))+xlab("Family Type and Employment Status ")+ylab("Percentage")+geom_bar(stat="identity")+ggtitle("Percentage of NOC under different FES") + theme(legend.position="bottom")
# by number
ggplot(work3,aes(x=FES,y=n,fill=factor(NOC)))+xlab("Family Type and Employment Status ")+ylab("Total number")+geom_bar(stat="identity")+ggtitle("Total number of NOC under different FES") + theme(legend.position="bottom")
# sankey plot
SKdata <- data.frame(From=c(rep("Both in Labor Force",12),rep("Only Husband in Labor Force",12),rep("Only Wife in Labor Force",12),rep("Neither in Labor Force",12),
                            rep("Male in Labor Force",12),rep("Male not in Labor Force",12),rep("Female in Labor Force",12),rep("Female not in Labor Force",12)),
                     To=c(rep(c("1","2","3","4","5","6","7","8","9","10","11","12"),8)),
                     Weight=c(40.92,41.22,13.72,3.17,0.68,0.18,0.07,0.03,0.01,0,0,0,31.47,38.59,19.52,7.11,1.99,0.77,0.29, 0.15,0.07,0.03,0.01,0,47.26,35.25,12.27,3.57,1.05,0.33,
                              0.18,0.06,0.02,0.01,0,0,49.46,30.02,12.32,5.53,1.34,0.72,0.41,0.08,0.08,0.03,0.03,0,55.22,30.64,10.24,2.93,0.74,0.16,0.06,0.01,0,0,0,0,62.77,24.31,8.81,
                              2.96,0.76,0.25,0.13,0,0,0,0,0,51.55,31.85,11.90,3.45,0.89,0.26,0.07,0.02,0.01,0,0,0,43.74,31.90,15.28,6.07,1.97,0.73,0.19,0.09,0.02,0.02,0,0.01))
Sankey <- gvisSankey(SKdata, from="From", to="To",weight="Weight",options=list(sankey="{link: {color: { fill: '#d799ae' } },
                            node: { color: { fill: '#a61d4c' },
                            label: { color: '#871b47' } }}"))
plot(Sankey)

# From the ggplot above, we can find that few family will have more than four children, so our focus will be on four children and married couple.
SKdata1 <-data.frame(From=c(rep("Both in Labor Force",4),rep("Only Husband in Labor Force",4),rep("Only Wife in Labor Force",4),rep("Neither in Labor Force",4)),
                     To=c(rep(c("1","2","3","4"),4)),
                     Weight=c(40.92,41.22,13.72,3.17,31.47,38.59,19.52,7.11,47.26,35.25,12.27,3.57,49.46,30.02,12.32,5.53))
Sankey1 <- gvisSankey(SKdata1, from="From", to="To",weight="Weight",options=list(sankey="{link: {color: { fill: '#d799ae' } },
                            node: { color: { fill: '#a61d4c' },
                            label: { color: '#871b47' } }}"))
plot(Sankey1)
# From the bubble chart, we can find that Married-couple, only husband in Labor Force that has a biggest mean number of childern.
# By looking at the percentage, we can find that only husband in Labor Force tend to have more children.
# Then we want to dig out more about the FES in different status.
high <- sqldf('SELECT df.NOC, df.FES, df.name from df where name in ("Utah","Idaho","Alaska","North Dakota","South Dakota")')
low <- sqldf('SELECT NOC, FES, name from df where name in ("District of Columbia","New Hampshire","West Virginia","Vermont","Rhode Island")')
# Then we want to study the relationship between state and FES
# study the fist five rank high states
high1 <- select(high, FES,name) %>% na.omit()
statehigh <- high1 %>% group_by(name,FES) %>% summarise(n=n()) %>% mutate(percentage = n/sum(n) * 100)
statehigh <- mutate(statehigh,percentage = round(percentage,2))
statehigh <- sqldf('SELECT statehigh.name, statehigh.FES,statehigh.n,statehigh.percentage, codeoffes.FamilyTypeEmploymentStatus from statehigh,codeoffes where statehigh.FES=codeoffes.FES')
ggplot(statehigh,aes(x=name,y=percentage,fill=factor(FamilyTypeEmploymentStatus)))+xlab("The first five states which have the highest NOC")+ylab("Percentage")+geom_bar(stat="identity")+ggtitle("Percentage of FES in states with higher NOC") + theme(legend.position="bottom")
# study the last five states which have lower NOC
low1 <- select(low, FES, name) %>% na.omit()
statelow <- low1 %>% group_by(name,FES) %>% summarise(n=n()) %>% mutate(percentage = n/sum(n)*100)
statelow <- mutate(statelow, percentage = round(percentage,2))
statelow <- sqldf('SELECT statelow.name,statelow.FES,statelow.n,statelow.percentage, codeoffes.FamilyTypeEmploymentStatus from statelow, codeoffes where statelow.FES= codeoffes.FES')
ggplot(statelow, aes(x=name,y=percentage,fill=factor(FamilyTypeEmploymentStatus)))+xlab("The last five states which have the lowest NOC")+ylab("Percentage")+geom_bar(stat="identity")+ggtitle("Percentage of FES in states with lower NOC") + theme(legend.position = "bottom")
# compare these two graphs, we can find that States, which have higher number of children, "Both in Labor Force" and "Only husband in Labor force" have larger percentage.
# However, states, which have lower number of children, "Both in Labor Force" and "Female in Labor Force" have larger percentage.
# Hence, we can conclude that Family Type and Employment Status will affect the number of children. 