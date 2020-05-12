#

weekdaysPer6To8Hour    <- full.data %>% filter(train_test == 'train'
) %>% select(weekdays, X18.20_ride
) %>% group_by(weekdays) %>%  dplyr::summarise(count = sum(X18.20_ride))

#' 월,화가 가장 많고, 토,일 인원이 상대적으로 작음
#' 해당 컬럼을 변수로 추가해야함

p <- plot_ly(
  x = reorder(weekdaysPer6To8Hour$weekdays, weekdaysPer6To8Hour$weekdays),
  y = weekdaysPer6To8Hour$count,
  name = "요일별 승차 18시 ~ 20시 통계 값",
  type = "bar"
)
print(p)
