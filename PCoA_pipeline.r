# MT整理于2018.12.06
library(ggplot2)
rawdata <- read.table("clipboard",header = T, row.names = 1, sep = "\t")# clipboard是剪切板，将此命令粘贴到R，打开数据进行选择粘贴，返回R运行即可。其中header=T 是列名称。row.names= 1 行名称，sep="\t"  表示以tab（制表符）为分隔符。
rawdata.pca <- prcomp(rawdata[,-1], scale=TRUE)#scale=TRUE是指对数据按列标准化，消除量纲对于数据处理的影响；需要去除含0的数据列，主要针对采用der2数据处理的例。prcomp（）函数对给定的数据矩阵执行主成分分析，并将结果作为prcomp类的对象返回。
variance=summary(rawdata.pca)#计算各主成分的比例即贡献率还有标准差，累计贡献率。
pca_vcar <- variance$importance[3,1:15]#将累计贡献率提取赋值于pca_vcar
ggplot(,aes(x=1:15,y=pca_cvar)) + geom_point(pch=2,lwd=3,col=2)+ geom_line(col=2,lwd=1.2)# 绘制累积贡献率图，pch表示点的形状，lwd表示点或线的宽度，col表示颜色。
scatterplot <- cbind(rawdata[1],rawdata.pca$x[,1:3])#生成一个复合文件（包括分组信息以及选择前三个主成分），
#scatterplot<- scatterplot[-3]#用于去掉不想要的主成分。此处减掉了PC2，后面的PC数做图时应做相应修改
ggplot(scatterplot,aes(x=PC1, y=PC2, fill=Group)) + geom_point(size=4,shape=21,colour="#FFFFFF")#画散点图，针对PC1和PC2。colour="#FFFFFF"背景或边框为白色。
ggplot(scatterplot,aes(x=PC1, y=PC2, fill=Group)) + geom_point(size=4,shape=21,colour="#FFFFFF") + stat_ellipse(geom = "polygon",alpha=0.1,linetype = 1,size=0.7,level=0.9) +  labs(x = "PC1 (21.27%)", y = "PC2 (8.6%)")
#绘制带置信椭圆的散点图。#geom用于设置填充形状（ploygon是多边形），alpha设置透明度（不设置是实心填充，会遮盖图中的点。level是设置椭圆的置信区间（椭圆大小），椭圆越小涵盖的点越集中，labs是加上对应坐标标签，里面贡献率根据实际成分修改）
ggsave(filename = "PCA.pdf", width = 20, height = 10)#生成pdf文件，并保存，如果需要编辑，采用AI打开进行局部修改



> ggplot(scatterplot1,aes(x=PC1, y=PC2, group=group)) + geom_point(aes(color = group, shape=group1), size=4,alpha = 0.8) + scale_shape_manual(values = c(17,19,15)) + stat_ellipse(geom = "polygon",alpha=0.1,linetype = 1,size=0.7,level=0.9) +  labs(x = "PC1 (16.71%)", y = "PC2 (13.25%)")