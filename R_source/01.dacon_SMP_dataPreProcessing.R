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

View(head(weatherV1))
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

## 2. 타입 변환
## 2.1 area : 지점 코드 : -> factor
weatherV1$area <- as.factor(weatherV1$area)

## 2.2 datetime : 일시 -> Date
weatherV1$datetime <- as.POSIXct(weatherV1$datetime, format = '%Y-%m-%d %H:%M')

weatherV1$date <- as.Date(weatherV1$datetime)

dateSplit           <- data.frame(do.call('rbind', strsplit(as.character(weatherV1$date), split='-', fixed=T))) 
colnames(dateSplit) <- c('year', 'month', 'day')
weatherV1           <- cbind(weatherV1, dateSplit)

## 2.3 temp(기온), prec(강수량), ws(풍속), wd(풍향), humid(습도), landp(현지기압), Seap(해면기압)
##    --> numeric (유지)

## 3. feature selection 
## 3.1 ASOS 온도 데이터만 사용.
weatherV1 <- weatherV1 %>% filter(station == 'ASOS') %>% dplyr::select(area, datetime, temp, station)

## 3.2 weekdays column 추가
weatherV1[,'weekdays'] <- weekdays(weatherV1$datetime)

## label encoding 수행
weekdays_encoder <- c(  '월요일' = 1
                        , '화요일' = 2
                        , '수요일' = 3
                        , '목요일' = 4
                        , '금요일' = 5
                        , "토요일" = 6
                        , '일요일' = 7
)

weatherV1$weekdays <- as.integer(plyr::revalue(weatherV1$weekdays, weekdays_encoder))

## 3.3 제주, 고산, 성산, 서귀포 (ASOS 지점) select
weatherV1 <- weatherV1 %>% filter(area %in% c('184', '185', '188', '189'))

## 3.4 지역별 기온의 중앙값 계산
medianByDateTime          <- weatherV1 %>% group_by(datetime, area) %>% dplyr::summarise(temp_median = median(temp)) %>% as.data.frame()
medianByDateTime$datetime <- as.Date(medianByDateTime$datetime)
## 3.5 선정된 시간별 기온에서 그 날의 최소기온, 최고기온, 평균기온를 찾아 target에 추가
head(medianByDateTime)
summariseByDate <- medianByDateTime %>% group_by(datetime) %>% dplyr::summarise(  temp_min = min(temp_median, na.rm = T),
                                                               temp_max = max(temp_median, na.rm = T),
                                                               temp_mean = mean(temp_median, na.rm = T)) %>% as.data.frame()

targetV1$date <- as.Date(targetV1$date)
targetV1 <- dplyr::inner_join(targetV1, summariseByDate, by = c('date' = 'datetime'))

