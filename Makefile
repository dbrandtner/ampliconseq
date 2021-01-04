len=50
pident=90

join:	##FastQC analysis, trimming and joining reads - default value are len=50 and pident=90
	@bash script/ampliconseq_join.sh $(len) $(pident)


align:	##Align joined reads to reference - type ref=g1 or ref=g2
ifeq ($(ref), g1)
	@echo Reference chosen: ${ref}
	@bash script/ampliconseq_align.sh ${ref}
else  
ifeq ($(ref), g2)
	@echo Reference chosen: ${ref}
	@bash script/ampliconseq_align.sh ${ref}	
else 
	@echo "ERROR: Reference invalid/not chosen, run again indicating as ref=g1 or ref=g2"
endif
endif


filter: ## Filter alignment - type pid=int number as %identity and ref=g1 or ref=g2
ifeq ($(shell expr $(pid) ">=" 90), 1)
	@echo pid selected threshold: ${pid}%
	@echo '-- Minumum allowed 90% (default) --'
ifeq ($(ref), g1)
	@echo Reference chosen: ${ref}
	@bash script/ampliconseq_filter.sh ${ref} ${pid}
else ifeq ($(ref), g2)
	@echo Reference chosen: ${ref}
	@bash script/ampliconseq_filter.sh ${ref} ${pid}	
else 
	@echo "ERROR: Reference invalid/not chosen, run again indicating as ref=g1 or ref=g2"

endif
else
	@echo ERROR: invalid threshold
	@echo pid selected threshold: ${pid}%
	@echo '-- Minumum allowed 90% (default) --'
endif

allpooltab:	## Construct genotype pool table for plotting - type ref=g1 or ref=g2
ifeq ($(ref), g1)
	@echo Reference chosen: ${ref}
	@echo "Constructing g1 table for plotting"
	@cat results/*_result${ref}_*.tsv > results/allpool/allpool_${ref}.tsv
else  
ifeq ($(ref), g2)
	@echo Reference chosen: ${ref}
	@echo "Constructing g2 table for plotting"
	@cat results/*_result${ref}_*.tsv > results/allpool/allpool_${ref}.tsv	
else 
	@echo "ERROR: Reference invalid/not chosen, run again indicating as ref=g1 or ref=g2"
endif
endif

clear:	## Clear results
	@bash script/ampliconseq_clear.sh


help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)


