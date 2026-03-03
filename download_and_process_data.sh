while read -r url; do
    echo "Downloading: $url"
    wget -c "$url"
done < file_url.txt

echo ">>> Successful! All files are downloaded."

gzip -dv *.gz
tar -av *.zip

echo ">>> Files are unzipped."

mv pbr.v1.1.pep pb.all.pep
mv pbr.v1.1.chr.fa pb.chr
mv pbr.v1.1.chr.gff3 pb.gff3
mv Arabidopsis_thaliana.TAIR10.dna.toplevel.fa ath.chr
mv Arabidopsis_thaliana.TAIR10.62.gff3 ath.gff3
mv PN40024_5.1_on_T2T_ref_with_names.gff3 vv.gff3
mv 5.1_on_T2T_ref_main_proteins.fasta vv.all.pep
mv T2T_ref.fasta vv.chr
mv Antonovka_hapolomeA.fa md.chr
mv Antonovka_hapolomeA.gff3 md.gff3
mv Antonovka_hapolomeA_pep.fa md.all.pep
mv Fragaria_vesca_v6_genome.fasta fv.chr
mv Fragaria_vesca_v6_genome.gff fv.gff3
mv Fragaria_vesca_v6_proteins.fasta fv.all.pep
mv Lovell_2D_v3.0.scaffold.fa pp.chr
mv Lovell_2D_v3.0.genes.gff3 pp.gff3
mv Lovell_2D_v3.0.proteins.fa pp.all.pep
mv S_lycopersicum_chromosomes.4.00.fa sl.chr
mv ITAG4.0_gene_models.gff sl.gff3
mv ITAG4.0_proteins.fasta sl.all.pep
mv Neixiu_assembly-renamed.fa cs.chr
mv Neixiu_v1-proteins.fasta cs.all.pep
mv Chr_genome_all_transcripts_final_gene.gff3 cs.gff3

echo ">>> Files are renamed."

mkdir proteins
mkdir annotations
mkdir chromosomes
mkdir result
mkdir databases

mv *.pep ./proteins
mv *.gff3 ./annotations
mv *.chr ./chromosomes

