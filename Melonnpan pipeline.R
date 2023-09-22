# MT整理于20201120

## 抽取序列 seqtk抽取序列，1GB=1000000000bp 一条reads是125bp，双端数据就是250bp
#for i in `ls -d S*`; do seqtk sample -s 100 ${i}/${i}_1.fq.gz 500000 > ${i}/sub_${i}_1.fq.gz; done #这里抽取的是1000000reads，-s随机种子，r1和r2设置一样即可
# for i in `ls -d S*`; do seqtk sample -s 100 ${i}/${i}_2.fq.gz 500000 > ${i}/sub_${i}_2.fq.gz; done
ls -d C* | parallel -j 10 seqtk sample -s 100 {}/{}.clean.r1.fq.gz 500000 ">" {}/sub_{}_1.fq.gz
ls -d C* | parallel -j 10 seqtk sample -s 100 {}/{}.clean.r2.fq.gz 500000 ">" {}/sub_{}_2.fq.gz

mkdir subsample
for i in `ls -d S*`; do mv ${i}/sub* ./subsample; done
for i in `ls -d s*`; do mkdir ${i%_*}; mv ${i} ${i%_*}; done
cd ../
mv subsample ../../../1.1_Melonnpan/

# diamond 注释
cd 1.1_Melonnpan/subsample
ls -d  s* | parallel -j 5 diamond blastx --threads 10 --query-cover 90 --id 50 --db /userdata1/data_mat/database/uniref90.fasta.dmnd --query {}/{}_1.fastq.gz --out {}/{}.table_r1
ls -d  s* | parallel -j 5 diamond blastx --threads 10 --query-cover 90 --id 50 --db /userdata1/data_mat/database/uniref90.fasta.dmnd --query {}/{}_2.fastq.gz --out {}/{}.table_r2

ls -d sub* | parallel -j 10 get_besthits.sh {}/{}.table_r1 '>' {}/{}.table_r1.best
ls -d sub* | parallel -j 10 get_besthits.sh {}/{}.table_r2 '>' {}/{}.table_r2.beste

for i in `ls -d s*`; do cd ${i}; cat ${i}.table_r2.best ${i}.table_r1.best > ${i}.table.best; cd ../; done
for i in `ls -d s*`; do cd ${i}; less ${i}.table.best | cut -f 2 | sort --parallel=30 -S 20% | uniq -c | awk -F " " '{print $2 "\t" $1}' > ${i}.table.best.gene_count; cd ..; done

# 计算含量
# less -S sub_Sample_T8C.rmhost.table.best.gene_count | awk -F " " '{print $1, $2, $3, 1000000}' | awk -F " " '{print $1,$2, $3,$4,($2/$3)}'|  awk -F " " '{print $1, $2, $3, $4, $5, "Sample_T8C"}' > sub_Sample_T8C_content # 添加某列固定值，直接指定（$x, 具体数字）； 对指定列求和，求除，（$x, ($某列/$某列)）
# sed -i '1iID\tgene_num\ttotal_reads\tcontent\tSample' sub_Sample_T8C_content
for i in `ls -d s*`; do cd ${i}; less ${i}.table.best.gene_count | awk -F " " '{print $1, $2, $3, 1000000}' | awk -F " " '{print $1,$2, $3,$4,($2/$3)}' > ${i%.*}_content; cd ../; done
mkdir content
for i in `ls -d s*`; do cd ${i}; mv ./*_content ../content; cd ../; done

# 将每个文件的样品名字加入到对应的文件中;并合并文件加入标题
cd content
for i in `ls -d *content` ; do less $i | perl -e 'while(<STDIN>){chomp; print "$_\t@ARGV[0]\n" }' $i ;   done  | sed 's/sub_//g' | sed 's/_content//g' | sed "1iID\tgene_num\ttotal_reads\tcontent\tSample" > combine_merged
cat combine_merged | grep -v '^ID' | perl -lane '@F[0]=~/(.*)\|/; print "$1\t@F[2]\t@F[3]\t@F[4]"' > combine_merged.f

# 提取对应的Melonnpan对应的811个代谢物
csvtk join -t -T -H  combine_merged.f ../../811_names > content_merged.sub
sed -i "1iID\ttotal_reads\tcontent\tSample" content_merged.sub
# 切换到自己的环境再用下面这个脚本，旧版python识别不了index这个参数，旧版识别的是rows
python 20200402.pivot_table.py
# 选择特征值大于2
R -e 'dt = read.table("./relative_ab_matrix", sep="\t", header=T, row.names=1); b=""; c=1 ; for (i in 1:ncol(dt)){a = length(unique(dt[,i])); if(a>2){b[c]=i; c=c+1 }}; b=as.numeric(b); out = dt[, b]; write.table(out, file="relative_ab_matrix.f", sep="\t", quote=F, row.names=T, col.names = NA)'
#切换到这个R环境
/nvmessdnode4/opt/conda/envs/MelonnPan/bin/R # 3.6的R
/nvmessdnode3/opt/links/predict_metabolites.R -i relative_ab_matrix.f -o sub
mv subMelonnPan_Predicted_Metabolites.txt MelonnPan_Predicted_Metabolites.txt
chmod 7771 MelonnPan_Predicted_Metabolites.txt