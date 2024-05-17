cpu ?= 8

ifeq ($(strand_specific),yes)
        strandness = --rf --rna-strandness RF
else ifeq ($(strand_specific),no)
        strandness = 
endif

RNA_fragment_size := $(which RNA_fragment_size.py)
inner_distance := $(which inner_distance.py)
hisat2_extract_splice_sites := $(which hisat2_extract_splice_sites.py)

.PHONY:Alignment

Splicesite:
	@echo -e $(sample) extract_splice_sites start at [`date +"%Y-%m-%d %H:%M:%S"`]
	python3 $(hisat2_extract_splice_sites) $(gtf) >$(outdir)/splicesites.txt
	@echo -e $(sample) extract_splice_sites end at [`date +"%Y-%m-%d %H:%M:%S"`]

Alignment:
	@echo -e $(sample) hisat2 alignment start at [`date +"%Y-%m-%d %H:%M:%S"`]
	mkdir -p $(outdir)/tmp
	if [ "$(seq_type)" = "PE" ] ;\
    then \
		hisat2 -x $(genome_index) -p $(cpu) --dta $(strandness) --known-splicesite-infile $(outdir)/splicesites.txt -1 $(fq1) -2 $(fq2) --un $(outdir) 2> $(outdir)/$(sample).hisat2.stderr| samtools sort -@ $(cpu) -m 768M > $(outdir)/$(sample).bam ;\
	else \
		hisat2 -x $(genome_index) -p $(cpu) --dta $(strandness) -U $(fq1) --known-splicesite-infile $(known_splicesites) -temp-directory $(outdir)/tmp 2> $(outdir)/$(sample).hisat2.stderr| samtools sort -@ $(cpu) -m 768M > $(outdir)/$(sample).bam ; \
	fi 
	samtools index -c $(outdir)/$(sample).bam
	#samtools view -f4 -b $(outdir)/$(sample).bam > $(outdir)/unmapped.bam
	#python3 bam_read.py -i $(outdir)/$(sample).bam -o $(outdir)/$(sample).mapping.rate
	#python3 infer_experiment.py -i $(outdir)/$(sample).bam -r $(gtf.bed) -s 500000 -q 20 > $(outdir)/$(sample).strandness.info
	@echo -e $(sample) hisat2 alignment end at [`date +"%Y-%m-%d %H:%M:%S"`]
	#@echo -e [Process:] `date` hisat2 Finished >> $(log_file)

InsertSize:
	@echo -e $(sample) InsertSize start at [`date +"%Y-%m-%d %H:%M:%S"`]
	perl ./gtf2bed.pl $(gtf) >$(outdir)/gtf.bed
	python3 $(inner_distance) -i $(outdir)/$(sample).bam -o $(outdir)/$(sample) -r $(outdir)/gtf.bed
	@echo -e $(sample) InsertSize end at [`date +"%Y-%m-%d %H:%M:%S"`]

FragSize:
	if [ "$(wildcard $(outdir)/gtf.bed)" == "" ] ;\
	then \
		perl ./gtf2bed.pl $(gtf) >$(outdir)/gtf.bed ;\
	fi
	@echo -e $(sample) FragSize start at [`date +"%Y-%m-%d %H:%M:%S"`]
	python3 $(RNA_fragment_size) -i $(outdir)/$(sample).bam -r $(outdir)/gtf.bed >$(outdir)/$(sample).fragsize
	@echo -e $(sample) FragSize end at [`date +"%Y-%m-%d %H:%M:%S"`]

HTseq:
	@echo -e $(sample) htseq-count start at [`date +"%Y-%m-%d %H:%M:%S"`]
	htseq-count -i gene_id -t exon -r pos -f bam -s no -a 10 -c $(outdir)/$(sample).htseq.count.tsv -q $(outdir)/$(sample).bam $(gtf)
	@echo -e $(sample) htseq-count end at [`date +"%Y-%m-%d %H:%M:%S"`]

