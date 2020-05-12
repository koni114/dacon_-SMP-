## 전력 수요 예측 경진대회
## 전력 수요 예측.
## 영향을 미칠 만 한 요소들..
## 기상데이터, 불쾌지수, 체감온도.
## 전력을 생산할 때 쓰이는 에너지 원료로는, 원자력, 석탄, LNG, 증유로 나눠짐.
## 전력이 많이 사용되지 않는 경우에는

## SMP 평균을 보면 여름하고 겨울에 높게 나옴
## 2020.05.25 ~ 2020.06.21 


## library loading
require(dplyr);require(data.table);require(plotly)
require(httr);require(dplyr);require(jsonlite);
require(geosphere)
require(caret);require(dplyr);require(mlbench);require(e1071);require(data.table)
require(klaR);require(pls);require(ipred);require(randomForest);require(sampling);require(glmnet)
require(xgboost);require(randomForest);require(caret)
    

## source loading
source('./04.dacon_SMP_common.R')


list.files(path = "../input/dacon-14th/")
path.dir <- "./SMP/"

weatherV1   <- fread(paste0(path.dir, 'weather_v1.csv'), encoding = 'UTF-8')
targetV1    <- fread(paste0(path.dir, 'target_v1.csv'), encoding  = 'UTF-8')        # 일별 SMP max, min, mean, supply
hourlySmp   <- fread(paste0(path.dir, 'hourly_smp_v1.csv'), encoding  = 'UTF-8')    # 시간별 SMP
lookUpTable <- fread(paste0(path.dir, 'lookupTable_area.csv'), encoding  = 'UTF-8') # 
  

# flag column factor type으로 변환
strFlag   <- names(weatherV1)[grep("Flag", names(weatherV1))]
weatherV1 <- weatherV1 %>% mutate_each_(funs(as.factor), strFlag)

## 1. 결측치 85% 이상인 변수 제거. 
wtrIsRate <- isNaRate(weatherV1)
weatherV1 <- weatherV1[,-which(wtrIsRate > 0.85)]


## 최종 사용 컬럼
colnames(weatherV1)


## 2. 타입 변환
## 2.1 area : 지점 코드 : -> factor
weatherV1$area <- as.factor(weatherV1$area)

## 2.2 datetime : 일시 -> Date
weatherV1$datetime <- as.Date(weatherV1$datetime)

## 2.3 temp(기온), prec(강수량), ws(풍속), wd(풍향), humid(습도), landp(현지기압), Seap(해면기압)
##    --> numeric (유지)














