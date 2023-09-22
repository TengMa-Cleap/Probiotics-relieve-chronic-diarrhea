# procrustes analysis
library(reshape2)
library(ggplot2)
library(dplyr)
library(phyloseq)
library(ggsci)
library(ggpubr)
library(plyr)
library(ggpubr)
library(cowplot)
library(vegan)
library(ggcor)
library(ggcorrplot)

mp = read.table("clipboard", sep="\t", header=T, row.names=1)
# 指标
index = read.table("clipboard", sep="\t", header=T, row.names=1)
index_bray = vegdist(t(index[, 1:ncol(index)]), method = "bray") # 这里的1，2根据实际的其实样品列修改
INA = monoMDS(index_bray)$point %>% as.data.frame()
# 菌群
taxa_ab = read.table("clipboard", sep="\t", header=T, row.names=1)
taxa_ab_bray = vegdist(t(taxa_ab[, 1:ncol(index)]), method = "bray")
INB = monoMDS(taxa_ab_bray)$point %>% as.data.frame()
# 排序
INA = INA[order(rownames(INA)), ] ; 
INB = INB[order(rownames(INB)), ] ;
# procrustes
procrustes.results <- ade4::procuste(INA, INB)
A = procrustes.results$tabX %>% as.data.frame() ; A$Sample = rownames(A)
B = procrustes.results$tabY %>% as.data.frame() ; B$Sample = rownames(B)
INA_sp = INA;  INA_sp$Sample = rownames(INA)
INB_sp = INB;  INB_sp$Sample = rownames(INB)

plot_pro = rbind(INA_sp, INB_sp) #plot_pro = rbind(INA_sp, A,INB_sp, B) 这个把所有的都连线了
plot_pro$method = rep(c("index", "taxa"), each = 314) #根据具体情况修改 each = xx 对应plot_pro的obs/2得出，做这个分析时候两组 人数一定要相等！！！！！
plot_pro = merge(plot_pro, mp, by = "Sample")

###P值
pro_test = protest(X = INA, Y = INB, scores = "sites", permutations = 999) #pro_test这里面有对应的相关关系系数Correlation in a symmetric Procrustes rotation: 0.3444 
plot_pro_ggpt = ggplot(plot_pro, aes(MDS1, MDS2, color = Time, shape = method)) + 
    geom_point(size = 3) +
    geom_line(aes(group = Sample, color = Time), alpha=0.5) + 
    ggtitle("Procruste rotation comparing NMDS from index to taxa; correlation = xx, p=xx") + scale_color_npg() + theme_bw()+ theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank()) #看具体前面结果修改xx

ggplot(plot_pro, aes(MDS1, MDS2, color = Time, shape = method)) + 
    geom_point(size = 3) +
    geom_line(aes(group = Sample, color = Time), alpha=0.5) + 
    ggtitle("Procruste rotation comparing NMDS from index to taxa; correlation = 0.782, p=0.001") + scale_colour_manual(values = c("#006837","#fc8d59","#253494","#bd0026","#9e9ac8","#4697AB")) + theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) # scale_colour_manual() 手动设置颜色这里