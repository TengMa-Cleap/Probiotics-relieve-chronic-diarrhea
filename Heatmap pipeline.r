#热图绘制--宏基因组公众号
data(mtcars)
View(mtcars)
data <-read.table("clipboard", row.names=1, header=T,sep = "\t") #矩阵就行 
df <- as.matrix((scale(data)))#归一化、矩阵化? ###对于不需要归一化的直接 df <- as.matrix(data)就行
heatmap(df, scale="none") #scale什么意思？row columa none
#Use custom colors使用定制颜色
col <- colorRampPalette(c("red", "white", "blue"))(256)
heatmap(df, scale = "none", col=col)
library(RColorBrewer)#创建漂亮的调色板，特别是地图
col <- colorRampPalette(brewer.pal(10, "RdYlBu"))(256) #自设置调色板3-11个区间变色，选定颜色
#参数RowSideColors和ColSideColors用于分别注释行和列颜色等,可help(heatmap)详情
heatmap(df, scale = "none", col=col, RowSideColors = rep(c("blue", "pink"), each=16),ColSideColors = c(rep("purple", 5), rep("orange", 6)))
#增强热图#还有其他参数可参考help(heatmap.2())
library(gplots)
heatmap.2(df, scale = "none", col=bluered(100),trace = "none", density.info = "none")

#交互式热图绘制
#函数d3heatmap()用于创建交互式热图，有以下功能：
#1、将鼠标放在感兴趣热图单元格上以查看行列名称及相应值
#2、可选择区域进行缩放
library(d3heatmap)
d3heatmap(df, colors = "RdBu", k_row = 4, k_col = 2)#k_row、k_col分别指定用于对行列中树形图分支进行着色所需组数
###绘制复杂热图：用于绘制复杂热图，它提供了一个灵活的解决方案来安排和注释多个热图。它还允许可视化来自不同来源的不同数据之间的关联热图
library(ComplexHeatmap)
#name热图名称
Heatmap(df, name = "mtcars")
#自设置颜色
library(circlize)
Heatmap(df, name = "mtcars", col = colorRamp2(c(-2, 0, 2), c("green", "white", "red")))
#使用调色板   
#自定义颜色
mycol <- colorRamp2(c(-2, 0, 2), c("blue", "white", "red"))
Heatmap(df, name = "mtcars",col = colorRamp2(c(-2, 0, 2), brewer.pal(n=3, name="RdBu")))
#column_title = "Column title", row_title ="Row title"#添加列标题和行标题
#column_title_side：允许的值为“top”或“bottom”
#row_title_side：允许的值为“左”或“右”（例如：row_title_side =“right”）
#row_title_gp：用于绘制行文本的图形参数；column_title_gp：用于绘制列文本的图形参数；column_title_gp =gpar(fontsize = 14, fontface = "bold")字体加粗
在上面的R代码中，fontface的可能值可以是整数或字符串：1 = plain，2 = bold，3 =斜体，4 =粗体斜体。如果是字符串，则有效值为：
“plain”，“bold”，“italic”，“oblique”和“bold.italic”
#显示行/列名称：
#show_row_names：是否显示行名称。默认值为TRUE
#show_column_names：是否显示列名称。默认值为TRUE  
#更改聚类外观
默认情况下，行和列是包含在聚类里的。可以使用参数修改：
cluster_rows = FALSE。如果为TRUE，则在行上创建集群；
cluster_columns = FALSE。如果为TRUE，则将列置于簇上。
#如果要更改树枝的高度或宽度，可以使用选项
column_dend_height和row_dend_width：row_dend_width = unit(2, "cm")，column_dend_height = unit(2, "cm")
library(dendextend)
#利用color_branches()自定义树状图外观
row_dend = hclust(dist(df)) # row clustering 计算行距离就是样品距离     如：dist（df，method="euclidean"）
col_dend = hclust(dist(t(df))) # column clustering计算列距离就是指标距离
Heatmap(df, name = "mtcars", col = mycol, cluster_rows =color_branches(row_dend, k = 4), cluster_columns = color_branches(col_dend, k = 2))#添加树枝颜色
#不同的聚类距离计算方式 clustering_distance_rows = "pearson" ,clustering_distance_columns = "pearson"
参数：
clustering_distance_rows和clustering_distance_columns
用于分别指定行和列聚类的度量标准，允许的值有“euclidean”, “maximum”, “manhattan”, “canberra”, “binary”, “minkowski”, “pearson”, “spearman”, “kendall”
#聚类方法
参数：
clustering_method_rows和clustering_method_columns可用于指定进行层次聚类的方法。允许的值是hclust()函数支持的值，包括"ward.D2"，“single”,“complete”，“average”，…（见hclust）
如：hclust(dist(df, method = "binary"), method = "single") binary距离方法；single聚类方法
#热图拆分
有很多方法来拆分热图。一个解决方案是应用k-means使用参数km。
在执行k-means时使用set.seed()函数很重要，这样可以在稍后精确地再现结果

set.seed(1122)
# split into 2 groupsHeatmap(df, name = "mtcars", col = mycol, km = 2)
# split by a vector specifying row classes， 有点类似于ggplot2里的分面 根据分组
Heatmap(df, name = "mtcars", col = mycol, split = mtcars$cyl )
#split也可以是一个数据框，其中不同级别的组合拆分热图的行
Heatmap(df, name ="mtcars", col = mycol, split = data.frame(cyl = mtcars$cyl, am = mtcars$am))


#热图注释
利用Heatmap Annotation()对行或列注释。格式为： Heatmap Annotation(df, name, col, show_legend)
df：带有列名的data.frame
name：热图标注的名称
col：映射到df中列的颜色列表
第一步：Annotation data frame注释数据框annot_df <- data.frame(cyl = mtcars$cyl, am = mtcars$am, mpg = mtcars$mpg)
第二步：为每个定性变量定义颜色，给连续变量定义渐变色
col = list(cyl = c("4" = "green", "6" = "gray", "8" = "darkred"), am = c("0" = "yellow",
"1" = "orange"), mpg = colorRamp2(c(17, 25), c("lightblue", "purple")) )
第三步：创建热图注释
ha <- HeatmapAnnotation(annot_df, col = col)
第四步：热图和注释结合
Heatmap(df, name = "mtcars", col = mycol, top_annotation = ha)
library("GetoptLong") 添加注释标签位置 左边或者右边
# Add annotation names on the right

for(an in colnames(annot_df)) {

seekViewport(qq("annotation_@{an}"))

grid.text(an, unit(1, "npc") + unit(2, "mm"), 0.5, default.units = "npc", just = "left")}
#要在左侧添加注释名称，请使用以下代码
# Annotation names on the left

for(an in colnames(annot_df)) { 
seekViewport(qq("annotation_@{an}")) 

grid.text(an, unit(1, "npc") - unit(2, "mm"), 0.5, default.units = "npc", just = "left")}
#可视化矩阵中列的分布
密度函数
使用函数densityHeatmap().
densityHeatmap(df)


