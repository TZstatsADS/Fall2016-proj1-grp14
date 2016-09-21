require(sqldf)
# NP, number of people records following this housing record
# BDSP, number of bedrooms
# RMSP, number of rooms
# RNTP, monthly rent
# VALP, property value
# FES, family type and employment status
# FINCP, family income
# GRPIP, gross rent as percentage of household income past 12 months
# HHL, Household language
# HINCP, Household income
# TAXP, Property tax
# WKEXREL, Work experience of householder and spouse
# WORKSTAT, Work status of householder or spouse in family households
# WGTP, Survey weights 
# Choose ss14husa.csv and ss14husb.csv
mydata_a <- read.csv(file.choose(), header = T, sep = ",")
mydata_b <- read.csv(file.choose(), header = T, sep = ',')
st <- read.csv(file.choose(), header = T, sep = ',')
mydata <- rbind(mydata_a, mydata_b)
cols_1<-c("NOC","NP","BDSP","RMSP","RNTP","VALP","FES","FINCP","GRPIP","HHL","HINCP",
          "TAXP","WKEXREL","WORKSTAT","WATP","GASP","FULP",
          "ELEP")
cols_st<-sqldf('SELECT st.name, st.abbr
            FROM st')
df1<-select(mydata,one_of(cols_1),156:235)
df<-cbind(cols_st,df1)
df<-as.data.frame(df)
#Using weights#
library(survey)
df<-svrepdesign(variables=df[,1:18], 
                 repweights=pus_new[,19:98], type="BRR",combined.weights=TRUE,
                 weights=df$WGTP)
summary(df)


#df<- sqldf('SELECT mydata.NOC, mydata.NP, mydata.BDSP, 
#                mydata.RMSP, mydata.RNTP, mydata.VALP, mydata.FES,
#            mydata.FINCP, mydata.GRPIP, mydata.HHL, mydata.HINCP,
#            mydata.TAXP, mydata.WKEXREL, mydata.WORKSTAT, mydata.WATP,
#            mydata.GASP, mydata.FULP, mydata.ELEP, st.name, st.abbr
#            FROM mydata, st
#            WHERE NOC >= 1
#            AND mydata.ST = st.code')

save(df, file = 'data.RData')
