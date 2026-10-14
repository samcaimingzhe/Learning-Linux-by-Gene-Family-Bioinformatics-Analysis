import sys
from Bio import SeqIO
from Bio.SeqUtils.ProtParam import ProteinAnalysis

def get_stats(fasta_file):
    STANDARD_AMINO_ACIDS = "ACDEFGHIKLMNPQRSTVWY"
    
    print("ID\tMW\tpI\tInstability\tAliphatic_Index\tGRAVY")
    
    for record in SeqIO.parse(fasta_file, "fasta"):
        original_seq = str(record.seq).upper()
        clean_seq = "".join([aa for aa in original_seq if aa in STANDARD_AMINO_ACIDS])
        
        if len(clean_seq) < 5:
            continue
            
        try:
            analysed = ProteinAnalysis(clean_seq)
            
            mw = analysed.molecular_weight()
            pi = analysed.isoelectric_point()
            instab = analysed.instability_index()
            gravy = analysed.gravy()
            
            f = analysed.amino_acids_percent
            ai = (f.get('A', 0) + 
                  2.9 * f.get('V', 0) + 
                  3.9 * (f.get('I', 0) + f.get('L', 0))) * 100
            
            print(f"{record.id}\t{mw:.2f}\t{pi:.2f}\t{instab:.2f}\t{ai:.2f}\t{gravy:.2f}")
            
        except Exception as e:
            print(f"Error processing {record.id}: {e}", file=sys.stderr)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 prot_analyzer.py input.fasta")
    else:
        get_stats(sys.argv[1])
