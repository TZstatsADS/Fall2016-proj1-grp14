require(sqldf)

# Choose ss14husa.csv and ss14husb.csv
mydata_a <- read.csv(file.choose(), header = T, sep = ",")
mydata_b <- read.csv(file.choose(), header = T, sep = ',')
st <- read.csv(file.choose(), header = T, sep = ',')
mydata <- rbind(mydata_a, mydata_b)
df <- sqldf('SELECT mydata.NOC, mydata.NP, mydata.BDSP, 
                mydata.RMSP, mydata.RNTP, mydata.VALP, mydata.FES,
            mydata.FINCP, mydata.GRPIP, mydata.HHL, mydata.HINCP,
            mydata.TAXP, mydata.WKEXREL, mydata.WORKSTAT, mydata.WATP,
            mydata.GASP, mydata.FULP, st.name, st.abbr
            FROM mydata, st
            WHERE NOC >= 1
            AND mydata.ST = st.code')

save(df, file = 'data.RData')
