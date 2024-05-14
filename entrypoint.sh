make -f /opt/Makefile sample=$INPUT_SAMPLE strand_specific=$INPUT_STRAND_SPECIFIC \
	seq_type=$INPUT_SEQ_TYPE genome_index=$INPUT_GENOME_INDEX gtf=$INPUT_GTF \
	cpu=$INPUT_CPU fq1=$INPUT_FQ1 fq2=$INPUT_FQ2 outdir=$INPUT_OUTDIR \
	Splicesite Alignment HTseq InsertSize FragSize
