#一键清空环境
rm(list = ls())
#加载原始数据
data <- read.csv("B-N_qc_data.csv",stringsAsFactors = FALSE)
#将原始数据中的0替换成NA
data[data==0] <- NA
mSet <- data
row.names(mSet) = mSet[,1]
cls <- mSet[1,-1]

library(stringr)
count = length(names(table(factor(cls[1,]))))
name = names(table(factor(cls[1,])))
str_glue("检测到数据中共有{count}个实验组，分别是：{name}")


#查看原始数据
orig_data <- mSet[-1,-1]

#step1 提取各个分组  paste("^",name[1],"$", sep = "")
group_1 <- as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[1]),cls)]))
group_2 <- as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[2]),cls)]))
group_3 <- as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[3]),cls)]))
group_4 <- as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[4]),cls)]))
group_5 <- as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[5]),cls)]))
group_6 <- as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[6]),cls)]))
group_7 <- as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[7]),cls)]))
# group_8<-as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[8]),cls)]))
# group_9<-as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[9]),cls)]))
# group_10<-as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[10]),cls)]))
# group_11<-as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[11]),cls)]))
# group_12<-as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[12]),cls)]))
# group_13<-as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[13]),cls)]))
# group_14<-as.data.frame(t(orig_data[,grep(sprintf("^%s$",name[14]),cls)]))

#step2 缺失值评估，将各组中缺失值(NA)数量>50%的代谢物全部替换成0
overhalf_replace_zero <- function(group){return(group <- apply(group,2,function(x) {
  if (sum(is.na(x))/nrow(group) > 0.5) {
    x[!is.na(x)] <- 0
    x[is.na(x)]<-0
  }
  x
}))
}

group_1 <- overhalf_replace_zero(group_1)
group_2 <- overhalf_replace_zero(group_2)
group_3 <- overhalf_replace_zero(group_3)
group_4 <- overhalf_replace_zero(group_4)
group_5 <- overhalf_replace_zero(group_5)
group_6 <- overhalf_replace_zero(group_6)
group_7 <- overhalf_replace_zero(group_7)
# group_8<-overhalf_replace_zero(group_8)
# group_9<-overhalf_replace_zero(group_9)
# group_10<-overhalf_replace_zero(group_10)
# group_11<-overhalf_replace_zero(group_11)
# group_12<-overhalf_replace_zero(group_12)
# group_13<-overhalf_replace_zero(group_13)
# group_14<-overhalf_replace_zero(group_14)

#step3 离异值删除,将<(下四分位数-1.5*IQR) 和 > (上四分位数+1.5*IQR)的值替换成NA
outliers_del <- function(group){return(apply(group,2,function(x){
  if (max(as.numeric(x),na.rm = TRUE)>(quantile(as.numeric(x), 3/4,na.rm = TRUE) + 1.5*IQR(as.numeric(x),na.rm = TRUE)) | min(as.numeric(x),na.rm = TRUE)<(quantile(as.numeric(x), 1/4,na.rm = TRUE) - 1.5*IQR(as.numeric(x),na.rm = TRUE)) ) {
    x[as.numeric(x)< (quantile(as.numeric(x), 1/4,na.rm = TRUE) - 1.5*IQR(as.numeric(x),na.rm = TRUE))] <- NA
    x[as.numeric(x)> (quantile(as.numeric(x), 3/4,na.rm = TRUE) + 1.5*IQR(as.numeric(x),na.rm = TRUE))] <- NA
  }
  x
}))}

group_1 <- outliers_del(group_1)
group_2 <- outliers_del(group_2)
group_3 <- outliers_del(group_3)
group_4 <- outliers_del(group_4)
group_5 <- outliers_del(group_5)
group_6 <- outliers_del(group_6)
group_7 <- outliers_del(group_7)
# group_8<-outliers_del(group_8)
# group_9<-outliers_del(group_9)
# group_10<-outliers_del(group_10)
# group_11<-outliers_del(group_11)
# group_12<-outliers_del(group_12)
# group_13<-outliers_del(group_13)
# group_14<-outliers_del(group_14)

#step4 缺失值(NA)替换 可选(平均值、中位数、最小值的一半)
#将缺失值替换成平均值
missingvalue_replace_with_mean <- function(group){return(apply(group, 2, function(x) {
  if (sum(is.na(x)) > 0) {
    x[is.na(x)] <- as.numeric(mean(as.numeric(x), na.rm = T))
  }
  x
}))}

#将缺失值替换成中位数
missingvalue_replace_with_median<-function(group){return(apply(group, 2, function(x) {
  if (sum(is.na(x)) > 0) {
    x[is.na(x)] <- as.numeric(median(as.numeric(x), na.rm = T))
  }
  x
}))}

#将缺失值替换成最小值的一半
missingvalue_replace_with_half_min<-function(group){return(apply(group, 2, function(x) {
  if (sum(is.na(x)) > 0) {
    x[is.na(x)] <- as.numeric(min(as.numeric(x), na.rm = T)/2)
  }
  x
}))}

#本次将NA替换成平均值
group_1 <- missingvalue_replace_with_mean(group_1) 
group_2 <- missingvalue_replace_with_mean(group_2) 
group_3 <- missingvalue_replace_with_mean(group_3) 
group_4 <- missingvalue_replace_with_mean(group_4) 
group_5 <- missingvalue_replace_with_mean(group_5)
group_6 <- missingvalue_replace_with_mean(group_6)
group_7 <- missingvalue_replace_with_mean(group_7)
# group_8<-missingvalue_replace_with_mean(group_8)
# group_9<-missingvalue_replace_with_mean(group_9)
# group_10<-missingvalue_replace_with_mean(group_10)
# group_11<-missingvalue_replace_with_mean(group_11)
# group_12<-missingvalue_replace_with_mean(group_12)
# group_13<-missingvalue_replace_with_mean(group_13)
# group_14<-missingvalue_replace_with_mean(group_14)


#step5 合并各组数据
all_groups <- t(rbind(group_1,group_2,group_3,group_4,group_5,group_6,group_7))
#将整行都是0的代谢物删除
all_groups <- all_groups[apply(all_groups,1,function(x){sum(as.numeric(x))})!=0,]


#step6 删除在各组强度都很低的代谢物(强度<100)，意味着峰高度不好，需要删除

all_groups <- t(apply(all_groups,1,function(x){
  if (mean(as.numeric(x[grep(name[1],cls)]))<100 & mean(as.numeric(x[grep(name[2],cls)]))<100 & mean(as.numeric(x[grep(name[3],cls)]))<100 & mean(as.numeric(x[grep(name[4],cls)]))<100 & mean(as.numeric(x[grep(name[5],cls)]))<100 & mean(as.numeric(x[grep(name[6],cls)]))<100 & mean(as.numeric(x[grep(name[7],cls)]))<100 
){
    x[x<100]<-0
    x[x>=100]<-0
    
  }
  x
}))

all_groups <- all_groups[apply(all_groups,1,function(x){sum(as.numeric(x))})!=0,]


#step7 “housekeeping”代谢物删除，该类代谢物在所有实验组中的含量相同。判定方法：sd值<10 即认为是“housekeeping”代谢物。这里name里设置成qc的组，前面有-号，是除去qc组的所有组，因为qc是稳定的。
# [4]这里因为qc是第四组，所以是4，具体情况根据QC在哪个组决定。

experimental_group <- all_groups[,-(grep(names(cls[,grep(name[4],factor(cls[1,]))])[1],colnames(all_groups)):grep(names(cls[,grep(name[4],factor(cls[1,]))])[length(names(cls[,grep(name[4],factor(cls[1,]))]))],colnames(all_groups)))]

all_groups <- all_groups[apply(experimental_group,1, sd, na.rm = T)>10,]

write.csv(all_groups,file = "B-P_select_result.csv")

#Try 失败 需跳过 这里也是修改name的4 改成对应qc的组别
QC1 <- all_groups[,names(cls[,grep(name[4],factor(cls[1,]))])]
table(apply(QC1,1,function(x){
  (sd(as.numeric(x))/abs(mean(as.numeric(x))))*100
})<30)

# QC2<-all_groups[,names(cls[,grep(name[13],factor(cls[1,]))])]
# table(apply(QC2,1,function(x){
#   (sd(as.numeric(x))/abs(mean(as.numeric(x))))*100
# })<30)
# 
# write.csv(all_groups,file = "wrong.csv")
# 
# 
# table(apply(QC1,1,function(x){
#   (sd(as.numeric(x))/abs(mean(as.numeric(x))))*100
# })<30 & apply(QC2,1,function(x){
#   (sd(as.numeric(x))/abs(mean(as.numeric(x))))*100
# })<30)



#step8 根据QC样本的RSD值(<30%)，删除重复性差的代谢物。 

all_groups <- all_groups[apply(QC1,1,function(x){
  (sd(as.numeric(x))/abs(mean(as.numeric(x))))*100
})<30,]

all_groups<-na.omit(all_groups)

#写出最终质控数据
all_groups<-rbind(cls, all_groups)
write.csv(all_groups,file = "B-P_select_RSD_result.csv") # RSD卡的太严格，后期做差异代谢分析合适，前面的分析就正常第七步就行





