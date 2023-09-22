#!/bin/bash
# Author：Jinhao 

function display_help() {
    echo ""
    echo -e "A pipeline for metagenome assembly and binning"
    echo -e "Author jinh"
    echo "-_-!!!"
    echo "   -s, --sample_list          A sample list which contained sample names and reads path as follows [*Required]"
    echo "Sample_A1 /userdata/data_jinh/Sample_A1.r1.fq.gz (split by tab)"   
    echo "Sample_A1 /userdata/data_jinh/Sample_A1.r2.fq.gz (split by tab)"
    echo "   -o, --outfolder            Output folder.  [*Required]"
    echo "   -t, --threads              Number of threads will be run. (Default: 30)"
    echo "   -m, --set_mem              The amount of memory used by the bwa mem, imput format should be 8G, 800Mb et al... (Default: 8G)"
    echo "   -h, --help                 Show this message"
    echo " "
    exit 1
}

# echo $#
if [ $# -eq 0  ];then
    echo "Please input parameters!"
    display_help
fi

## default settings.
sample_list="None"; outfolder="None"
threads=30
set_mem=8G

while [ "$1" != "" ]; do
    case $1 in
        -s | --sample_list )      shift
                                  sample_list=$1
                                  ;;
        -o | --outfolder)         shift
                                  outfolder=$1
                                  ;;
        -m | --set_mem)           shift
                                  set_mem=$1
                                  ;;
        -t | --threads)           shift
                                  threads=$1
                                  ;;
        * )                       display_help
                                  exit 1
    esac
    shift
done

##############
if [ $sample_list == "None" ] || [ $outfolder == "None" ]; then
    echo "Please input required parameters!"
    display_help
fi

new_sample_list=${outfolder}.snk.yaml
less $sample_list | perl -e 'while(<>){chomp; @s=split /\t/; if(@s[0] ne $n){print "$_\t"; $n=@s[0]}else{print "@s[1]\n"} }' > $new_sample_list

source activate snakemake
snakemake -s /ddnstor/imau_sunzhihong/mnt1/script/script/Bin_as_binning.py --config workdir=$outfolder set_mem=$set_mem file_names_txt=$PWD/$new_sample_list -p -r --cores $threads -j $threads  --keep-going 
