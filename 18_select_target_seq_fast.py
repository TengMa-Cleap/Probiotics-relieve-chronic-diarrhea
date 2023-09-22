#!/usr/bin/env python
# -*- coding:utf-8 -*-
#用于esom结果删除各个bin中的污染序列
"""
author: jin
date: 2018.11.17
function: none
usage: python ~ <old bin file> <del_seq_names> <Output file>
"""
import sys, os
from Bio import SeqIO
if len(sys.argv)!=4:
	print("Useage :python ~ < bin file> <target_seq_names> <Output file> ")
	sys.exit()
tmp=0 #counter
seq_names=open(sys.argv[2],"r")
outfile = open(sys.argv[3], 'w')
name_list={}
for line in seq_names:
    #print line
    line=line.strip()
    name_list[line]="a"

#Statistical duplication in list 
#name_list_stat=[]
#for i in name_list:
#    if name_list.count(i)>1:
#        name_list_stat.append(i)
#if name_list_stat:
#    set_list=set(name_list_stat)
#    print "There are \033[35;1m%s\033[0m duplication seq names,they are %s" %(len(set_list),i)
#else : print "No duplication names."
#print name_list
for seq in SeqIO.parse(sys.argv[1], "fasta"):
    #print seq.id
    #seq_id=seq.id.replace('.',"_")
    if seq.id in name_list:
        outfile.write(">" + seq.id + "\n" + str(seq.seq) + "\n")
        tmp+=1
    else:continue
outfile.close()
if tmp==0 :
    print("There is \033[32;1mno\033[0m selected sequence in \033[34;1m%s \033[0m" %sys.argv[1])
else : print("There are \033[31;1m%s\033[0m slected sequence in \033[34;1m%s\033[0m!" %(tmp,sys.argv[1]))
