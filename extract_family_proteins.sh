#!/bin/bash
# ==========================================
# Parameter Configuration Area
# ==========================================
GENE_NAME="galt"               # Gene family name
HMM_MODEL="PF01762"            # Your HMM model ID
BLAST_QUERY="ath.galt.pep"     # Query proteins
EVALUE="10"                    # E-value threshold for BLAST
# ==========================================

# ==========================================
# 1. Check Required Files & Software
# ==========================================
echo ">>> Checking required files and dependencies..."

CHECK_FAILED=0

[ -s "${BLAST_QUERY}" ] && echo " [OK] ${BLAST_QUERY} found." || { echo " [ERROR] ${BLAST_QUERY} not found or empty!"; CHECK_FAILED=1; }
[ -s "${HMM_MODEL}.hmm" ] && echo " [OK] ${HMM_MODEL}.hmm found." || { echo " [ERROR] ${HMM_MODEL}.hmm not found or empty!"; CHECK_FAILED=1; }

for cmd in hmmsearch makeblastdb blastp awk grep seqkit; do
    command -v ${cmd} > /dev/null 2>&1 && echo " [OK] Software: ${cmd}" || { echo " [ERROR] Software: '${cmd}' is missing!"; CHECK_FAILED=1; }
done
echo "=========================================="

if [ "$CHECK_FAILED" -eq 1 ]; then
    echo "Pre-flight check failed! Please fix the errors listed above and run again."
    exit 1
else
    echo "All checks passed! Starting main pipeline..."
fi
echo "=========================================="

# ==========================================
# 2. Main Pipeline Loop
# ==========================================
for file in /proteins/*.all.pep; do
    # Extract the filename prefix (e.g., get "pb" from "pb.pep")
    prefix=${file%.all.pep}
    echo ">>> Processing species: $prefix ..."

    # 1. HMM search (Using the downloaded .hmm file directly)
    hmmsearch --tblout /result/${prefix}.hmm.res ${HMM_MODEL}.hmm /proteins/${prefix}.all.pep > /dev/null
    
    # 2. Extract HMM IDs (excluding comment lines starting with '#')
    awk '{print $1}' /result/${prefix}.hmm.res | grep -v '#' > /result/${prefix}.hmm.id
    
    # 3. Build BLAST database (Output to log to keep terminal clean)
    makeblastdb -in /proteins/${prefix}.all.pep -input_type fasta -parse_seqids -dbtype prot -out /databases/${prefix}_db -logfile /dev/null
    
    # 4. BLASTP alignment
    blastp -task blastp -db /databases/${prefix}_db -query "${BLAST_QUERY}" -evalue "${EVALUE}" -outfmt 6 -out /result/${prefix}.blast.res
    
    # 5. Extract and deduplicate BLAST IDs
    awk '{print $2}' /result/${prefix}.blast.res | sort | uniq > /result/${prefix}.blast.id
    
    # 6. Get the intersection of HMM and BLAST IDs
    grep -Fxf /result/${prefix}.blast.id /result/${prefix}.hmm.id > /result/${prefix}.final.id
    
    # 7. Extract the final protein sequences
    seqkit grep -f /result/${prefix}.final.id /proteins/${prefix}.all.pep  -o /result/${prefix}.${GENE_NAME}.pep
    
    echo "$prefix Done"
    echo "------------------------------------"
done

# ==========================================
# 3. Merge All Results
# ==========================================
echo ">>> Merging all final sequences..."
cat /result/*."${GENE_NAME}".pep > /result/Merged."${GENE_NAME}".unsimplified.pep
seqkit replace -p "\s.+" -r "" Merged."${GENE_NAME}".unsimplified.pep > /result/Merged."${GENE_NAME}".simplified.pep

echo "Success! All sequences have been merged into Merged.${GENE_NAME}.simplified.pep"
