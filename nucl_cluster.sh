#!/usr/bin/sh
#jinh
#2020.01.01
function display_help(){
	echo "cluster with 95id 85cov"
	echo "Usage nucl_cluster.sh -i nucl.fasta -o cluster.out"
	exit
}
if [ $# -eq 0 ];then
    echo "Please input parameters!"
    display_help
fi

while [ "$1" != "" ]; do
    case $1 in
        -i | --fasta )          shift
                                rawdata=$1
                                ;;
        -o | --out_folder )     shift
                                outfolder=$1
                                ;;
        -h | --help )           display_help
                                exit
                                ;;
        * )                     display_help
                                exit 1
    esac
    shift
done

if [ ! -d $outfolder ];then
    mkdir $outfolder
else
    echo "Out folder already exist, so it will be removed!"
    rm -rf $outfolder
    mkdir $outfolder
fi

if [ ! -f $rawdata ];then
    echo "Input fasta not exists."
    exit
fi

script_folder=/ddnstor/imau_sunzhihong/mnt1/script/cluster_script
makeblastdb -in $rawdata  -dbtype nucl -input_type fasta -out ${outfolder}/bt.index
blastn -query $rawdata -db ${outfolder}/bt.index -out ${outfolder}/bt.out -outfmt 6 -evalue 1e-10 -num_alignments 1000000 -num_threads 50

perl ${script_folder}/get_length.pl $rawdata ${outfolder}/scaf.length
perl ${script_folder}/blast_cvg.pl ${outfolder}/bt.out ${outfolder}/bt.out.cvg
sort -k2 -nr ${outfolder}/scaf.length  | cut -f1,2 > ${outfolder}/scaf.length.sort
perl ${script_folder}/blast_cluster.pl ${outfolder}/scaf.length.sort ${outfolder}/bt.out.cvg ${outfolder}/bt.out.cvg.clstr
perl ${script_folder}/clstr_list.pl ${outfolder}/bt.out.cvg.clstr ${outfolder}/bt.out.cvg.clstr.list
perl ${script_folder}/get_fasta.pl ${outfolder}/bt.out.cvg.clstr.list $rawdata ${outfolder}/cluster.fasta
less ${outfolder}/bt.out.cvg.clstr | perl -e 'while(<>){chomp; if($_=~/^>/){$n=$_; next}; print "$_\t$n\n" }' | perl -ne 'chomp; $_=~/(\d+).*>(.*)\.\.\..*>(Cluster \d+)/; print "$2\t$3\t$1\n"' > ${outfolder}/bt.out.cvg.clstr.list




