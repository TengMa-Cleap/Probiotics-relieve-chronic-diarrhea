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
    echo "   -r, --rep_genome_folder    The absolute path of fasta or fa file of represent genomes directory"
    echo "   -o, --outfolder            Output folder.  [*Required]"
    echo "   -t, --threads              Number of threads will be run. (Default: 30)"
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

while [ "$1" != "" ]; do
    case $1 in
        -s | --sample_list ) shift
                                  sample_list=$1
                                  ;;
        -o | --outfolder)      shift
                                  outfolder=$1
                                  ;;
        -t | --threads)           shift
                                  threads=$1
                                  ;;
        -r | --rep_genome)        shift
                                  rep_outfolder=$1
                                  ;;                          
        * )                       display_help
                                  exit 1
    esac
    shift
done

##############
if [ $sample_list == "None" ] || [ $outfolder == "None" ] || [ $rep_outfolder == "None" ]; then
    echo "Please input required parameters!"
    display_help
fi

if ! [[ $rep_outfolder == /* ]]; then
    echo "Please input the absolute path of fasta or fa file of represent genomes directory!!!"
    exit
fi

new_sample_list=${outfolder}.snk.yaml
less $sample_list | perl -e 'while(<>){chomp; @s=split /\t/; if(@s[0] ne $n){print "$_\t"; $n=@s[0]}else{print "@s[1]\n"} }' > $new_sample_list

source activate snakemake
snakemake -s /ddnstor/imau_sunzhihong/mnt1/script/script/Bin_abundance.py --config workdir=$outfolder file_names_txt=$PWD/$new_sample_list rep_genome=$rep_outfolder -p -r --cores $threads -j $threads -k
