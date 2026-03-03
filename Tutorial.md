# 基因家族生物信息学分析指北——用生物信息学入门Linux
**致各位大四农科生们：**

> 本教程适用于想要学习Linux入门生物信息学的研0学子们。
> 
> 你是一个即将毕业的大四农科生，莫名其妙被老师安排做一个生物信息学毕设，题目好像是什么东西的基因家族生物信息学分析。你不懂什么是生物信息学分析，你很想接触了解一下，但不知道从何开始。看这一篇教程足矣。
> 
> 你毕业论文就是找到别人已经鉴定出来的一批蛋白质，这一批蛋白质具有很大的相似性，而这种相似性不只存在于这个物种，是在整个植物界乃至整个生物界可能都非常相似。所以你要去找到这一批蛋白的序列是什么，并且像《灰姑娘》中的王子一样拿着水晶鞋（参考物种的基因家族蛋白）去找整个城市的人（你需要做的物种的基因组的全部蛋白）一个一个试鞋（分析），最终找到你的灰姑娘（你需要做的物种的基因家族蛋白）。一开始大概做的是这么一件事情，之后就是对你找到蛋白质进行一些流程化的分析，得到一个规范化的结论。最后还有可能需要做一个qPCR验证这个基因家族蛋白的表达模式会受到胁迫或者激素的调控，也就是有一部分湿实验。
> 
> 目前关于基因家族分析的教程很多，但是以Linux为主且比较全面的较少。而且很多同学可能会希望入门Linux生物信息学分析，本教程会给大家示范如何使用Linux完成一整套基因家族分析，这不只是一个基因家族分析的教程，还是一份Linux入门的教程。

# 我们来了解一下需要使用到的文件和数据库
我们所需要的文件本质上都是文本文件。
**fasta：专门用于储存序列的文件**
- 大于号>表示序列ID，下面是序列
- 一个fasta文件里可以包含一个或者多个序列。以下展示的是蛋白质序列，fasta还可以储存DNA序列、RNA序列。如果是基因DNA序列则不会太长，文件较小。但若是染色体DNA序列，文件会很大。
```
>sp|Q9FGX2|BZIP1_ARATH Basic leucine zipper 1 OS=Arabidopsis thaliana OX=3702 GN=BZIP1 PE=1 SV=1
MANAEKTSSGSDIDEKKRKRKLSNRESARRSRLKKQKLMEDTIHEISSLERRIKENSERC
RAVKQRLDSVETENAGLRSEKIWLSSYVSDLENMIATTSLTLTQSGGGDCVDDQNANAGI
AVGDCRRTPWKLSCGSLQPMASFKT

>sp|Q9SI15|BZIP2_ARATH bZIP transcription factor 2 OS=Arabidopsis thaliana OX=3702 GN=BZIP2 PE=1 SV=1
MASSSSTYRSSSSSDGGNNNPSDSVVTVDERKRKRMLSNRESARRSRMRKQKHVDDLTAQ
INQLSNDNRQILNSLTVTSQLYMKIQAENSVLTAQMEELSTRLQSLNEIVDLVQSNGAGF
GVDQIDGCGFDDRTVGIDGYYDDMNMMSNVNHWGGSVYTNQPIMANDINMY
```

**gff3：专门用于储存基因的染色体位点的文件**
- 第1列：染色体号，有时按照数字1234等、有时按照Chr1234等、有时是Scaffold或Contig（这种情况可能是组装级别还达不到染色体、一般我们分析很少会用到带Scaffold或Contig，在选择基因组初期要筛选）。
- 第3列：类型，一般有gene、mRNA、CDS、exon、UTR等等。一般情况下gene等于mRNA，但是注意他们ID不一样，同样的gene会有多个mRNA，第一个mRNA是最长的剪切，可以等价于gene，比如例子中的gene是AT1G01010，mRNA是AT1G01010.1，之后还有.2.3.4等等更短的剪切。我们分析一般取.1即可。
- 第4-5列：起始与终止位点
- 第7列：正负链（不常用）
- 第9列：描述，一般只用到最前面的基因ID。
```
1	araport11	gene	3631	5899	.	+	.	ID=gene:AT1G01010;Name=NAC001;biotype=protein_coding;description=NAC domain containing protein 1 [Source:NCBI gene (formerly Entrezgene)%3BAcc:839580];gene_id=AT1G01010;logic_name=araport11
1	araport11	mRNA	3631	5899	.	+	.	ID=transcript:AT1G01010.1;Parent=gene:AT1G01010;Name=NAC001-201;biotype=protein_coding;tag=Ensembl_canonical;transcript_id=AT1G01010.1
1	araport11	five_prime_UTR	3631	3759	.	+	.	Parent=transcript:AT1G01010.1
1	araport11	exon	3631	3913	.	+	.	Parent=transcript:AT1G01010.1;Name=AT1G01010.1.exon1;constitutive=1;ensembl_end_phase=1;ensembl_phase=-1;exon_id=AT1G01010.1.exon1;rank=1
1	araport11	CDS	3760	3913	.	+	0	ID=CDS:AT1G01010.1;Parent=transcript:AT1G01010.1;protein_id=AT1G01010.1
```
为了方便后续使用这些文件，我们通常把原文件重命名，按照物种名和文件存储内容，比如拟南芥染色体基因组（ath.chr或ath.fa）、拟南芥蛋白质（ath.pep/ath.prot）、拟南芥基因注释文件（ath.gff3）。chr取自chromosome、pep取自peptide、prot取自protein。简单的文件名会让我们在输入文件路径的时候更加方便。

## 如何在你的基因组中鉴定出你的基因家族
我们需要：
- 基因组文件：染色体文件（fasta）、蛋白质文件(fasta)、基因注释文件(gff3)
- 基因家族文件： 目标蛋白文件（fasta）

根据物种来判断你需要从什么数据库找到这些文件
- 双子叶植物一般以拟南芥作为参考
- 单子叶植物以玉米、水稻、小麦、大麦、大豆作为参考。

## 找到你的基因家族蛋白质文件
我们需要：
- 参考物种基因组此基因家族的蛋白质序列fasta
- 此基因家族的隐马尔可夫Profile文件

举个例子，假设我们的目的是找到苹果中bZIP家族的蛋白质，我们就需要在TAIR中找到拟南芥全部的bZIP蛋白质序列。

以拟南芥（_Arabidopsis thaliana_）为例，其官方数据库为[The Arabidopsis Information Resource (TAIR)](https://www.arabidopsis.org/ )（这个网站需要在有校园网的条件下进入才能完全使用）
 
当然寻找蛋白质我们不只有TAIR，我们还有非常多蛋白质数据库：
- [Uniprot](https://www.uniprot.org/)：一个我个人非常喜欢、强烈推荐的一个去冗余的蛋白质数据库。界面干净友好、链接多种数据库。
- [RefSeq](https://www.ncbi.nlm.nih.gov/refseq/)：NCBI的蛋白质数据库，初期不推荐使用，因为存在冗余序列。
- [PDB](https://www.rcsb.org/)：蛋白质结构数据库，有实验室获取的蛋白质晶体结构，目前不在本课题的讨论范围之内。
- [AlphaFold Protein Structure Database](https://alphafold.ebi.ac.uk/)：AlphaFold蛋白质结构数据库，后期可能会用到。
**解释一下“去冗余”**：简单来说，去冗余就是剔除数据库中高度相似或重复的信息，只保留具有代表性的序列。某些热门蛋白（如血红蛋白、胰岛素）可能被成千上万次重复测序并上传，他们命名不同，但本质上就是同一种蛋白质。

同样在此罗列一些植物基因组数据库，方便我们后续下载基因组
- Ensembl Plants：大部分植物 https://plants.ensembl.org/index.html
- Phytozome：大部分植物 https://phytozome-next.jgi.doe.gov/ （我是最不推荐这个的，因为又要注册账号，下载又慢）
- Genome Database for Rosaceae (GDR)：蔷薇科植物 https://www.rosaceae.org/
- Citrus Genome Database (CGD)：柑橘属植物 https://www.citrusgenomedb.org/
- Pear Genomic Database (PGDB)：梨属植物 http://pyrusgdb.sdau.edu.cn/
- GrapeGenomics：葡萄科植物 https://www.grapegenomics.com/
- Grapedia：葡萄科植物 https://grapedia.org/genomes/
- Rice Genome Annotation Project：水稻 https://rice.uga.edu/
- Sol Genomic Network：茄科植物 https://solgenomics.net/
- International Wheat Genome Sequencing Consortium (IWGSC)：小麦 https://www.wheatgenome.org/
- SoyBase：大豆 https://www.soybase.org/
- MaizeGDB：玉米 https://www.maizegdb.org/
- COTTONGEN：棉花 https://www.cottongen.org/
- CGD：菊花 https://cgd.njau.edu.cn
- CuGenDBv2：葫芦科 http://cucurbitgenomics.org/v2/
- BRAD：十字花科 http://brassicadb.cn/#/

特别特别特殊的物种，可以在论文里查看是从哪获取的，可以到NCBI到数据库里再找找看。同时请注意并非所有的基因组都来自公共数据库，他们可能来自一些实验室内部的测序数据。

# 让我们一起开始探索基因家族的宇宙吧！
我们的操作系统是MacOS，只需要终端，建议安装一个[Warp]( https://www.warp.dev/)
如果是Windows系统，请安装Linux虚拟机或者[WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/install)

如果你做的是我们耳熟能详的基因家族，比如：bZIP、MAPK、MYB、NAC、U-box、WRKY、WOX等等。
则进入网站后点击 Browse -> Gene Families，或者点击这个网址 https://www.arabidopsis.org/browse/gene_family
但是你也可能被安排做一个不那么广为人知的基因家族、比如半乳糖基转移酶。那我们该怎么办呢？

首先我们可以从一些论文中获得，如果这个基因家族在其他物种中有研究过，他们可能会提供在参考物种基因组（比如拟南芥）的蛋白质序列（不太可能）或者蛋白质ID（有些可能），以及pfam号（很有可能）。

## 我们先定个题目
假设你的导师给你安排了《苹果半乳糖基转移酶基因家族分析》这个本科毕业论文的题目。我们需要通过：
- 拟南芥半乳糖基转移酶基因家族的蛋白质序列：TAIR或者Uniprot
- 半乳糖基转移酶基因家族的pfam号：论文里找，你会找到 _PF01762_
- 苹果的蛋白质序列文件：在GDR中
- 半乳糖基转移酶的英文名：_Galactosyltransferase_

## 如何找到基因家族的pfam号
最快的方法就是找论文，进入[PubMed](https://pubmed.ncbi.nlm.nih.gov/)，搜索 Galactosyltransferase Gene Family。或者在Bing上搜索，并非只有论文数据库才是你找论文的地方，Bing同样能帮你找到很多论文，而且效果可能会更好。
在Interpro中[Search by text](https://www.ebi.ac.uk/interpro/search/text/)直接搜索Galactosyltransferase也是可以的，搜索完看Source database，找PFAM就能找到PF01762。

**或者问问Kimi、豆包、Deepseek、千问，他们也许能帮你找到。**
这是Kimi的答案：

<img width="803" height="548" alt="Image" src="https://github.com/user-attachments/assets/83626c6d-fc34-4a85-9d26-f4c31628879c" />

还有一个办法，前提是我们老师有给我们一些参考的蛋白质，假设你有一条“未知蛋白1号”的fasta。可以贴到[CD-Search](https://www.ncbi.nlm.nih.gov/Structure/cdd/wrpsb.cgi)里，Search against database选择Pfam，可以帮我们找到一些可能的pfam号。
<img width="1439" height="792" alt="截屏2026-03-03 上午2 18 13" src="https://github.com/user-attachments/assets/b3d6aa30-d786-4852-a1c4-d412f0b86de8" />

总而言之，我们的办法有很多。

找到pfam号后点击进入网页，点击左边的Profile HMM，看到中间的Download继续点击。我们所需的Profile HMM文件就下载下来了，格式为压缩包gz。可以双击解压，如果你有安装相关的解压软件，或者进入终端（建议直接使用[Warp](https://www.warp.dev/)）：

> 我们要开始了解Linux command了！

```bash
cd ~/Desktop
mkdir GeneFamilyAnalysis
cd GeneFamilyAnalysis
mkdir LearnIdentification
cd LearnIdentification
mv ~/Downloads/PF01762.hmm.gz ~/Desktop/GeneFamilyAnalysis/LearnIdentification
gzip -d PF01762.hmm.gz
```
- `cd`：change directory，我们想到达哪个文件夹就需要对应的路径。
- `mkdir`：make directory，新建一个文件夹。
- `mv`：move，把文件移动到其他路径。
- `gzip`：压缩文件为gz压缩包的工具，-d是使用解压功能，这会把PF01762.hmm.gz解压为PF01762.hmm。

如果你想知道我们目前在哪个文件夹可以使用`pwd`，意思是print working directory。如果在打开终端后输入就会得到`/Users/YourUserName`，这里YourUserName就是你电脑的名字，一般 Macbook 就是你自己的名字，是你一开始在电脑里设定好的，Linux会是`/home`，Windows的WSL也是`/home`。我们可以用`~/`代替。这也就是为什么我们一开始`cd ~/Desktop`。

## 如何找到参考物种此基因家族的蛋白质序列
我们优先使用Uniprot，输入我们的基因家族名称，然后勾选Status中Reviewed (Swiss-Prot)与Popular Organism的A.thaliana。选择第一个蛋白质[Q8L7F9](https://www.uniprot.org/uniprotkb/Q8L7F9/entry)

<img width="1440" height="813" alt="Image" src="https://github.com/user-attachments/assets/35ab421b-a6c9-4488-b493-a994d3be361b" />

为什么要这样做，因为在上面提到过，这个数据库的数据最全面、去冗余、以及链接了其他数据库。如果我们直接在TAIR中搜Galactosyltransferase将不会出现任何结果。这是很奇怪的但也是这个数据库存在的问题。我们只能先从过Uniprot找到一个蛋白质再深入。

<img width="1439" height="547" alt="Image" src="https://github.com/user-attachments/assets/fb6a6221-86ce-454b-a0c7-ced1efb366c9" />

当我们划到 Names & Taxonomy 我们可以看到关于这个蛋白质的名称、相关论文链接等等。这些论文链接也是值得看看的。我们注意到 Organism-specific databases，有TAIR的链接，可以直接带我们过去（需要校园网）。

<img width="961" height="105" alt="Image" src="https://github.com/user-attachments/assets/d7210014-2ade-4ab3-97a0-a973c780d431" />

不过我们已经从此知道名称是GALT1，也就是说很可能在TAIR中的命名都是以GALT开始的，我们不妨试一试。

<img width="1439" height="813" alt="Image" src="https://github.com/user-attachments/assets/3b488d73-3e2e-496f-850e-bc7584f565b5" />

结果不出所料，我们找到了12个结果。自此我们开始使用AtGALT来统称拟南芥的半乳糖基转移酶。我们点击 Select All 把12个AtGALT都选上，再点击Get Sequence。Select Option 选择 Araport11 protein sequences 后会跳转一个页面，里面是我们需要的12个AtGALT蛋白质的fasta，我们需要全选复制粘贴到我们的新建文件。这里要注意一个学术规范，蛋白质用正体比如 AtGALT1，基因用斜体比如 *AtGALT1*。
```bash
vim at.galt.pep
```
我们会进入这个文件，点击键盘 `i`键，代表insert，我们会看到终端左下角出现了`-- INSERT --`，这说明我们可以写入，我们把公共复制的fasta文本粘贴完后点击键盘 `esc`键，然后输入`:wq`，代表write和quit。这样子我们就写入好一个at.galt.pep了。
我们需要的AtGALTs如下：
```bash
>AT1G08280.1 | Symbols: GALT29A | glycosyltransferase 29A | chr1:2608408-2609604 FORWARD LENGTH=398
MKRSVRPLFSALLFAFFAATLICRVAIRRSSFSFASAIAELGSSGLMTEDIVFNETLLEFAAIDPGEPNFKQEVDLISDYDHTRRSHRRHFSSMSIRPSE
QQRRVSRDIASSSKFPVTLRSSQAYRYWSEFKRNLRLWARRRAYEPNIMLDLIRLVKNPIDVHNGVVSISSERYLSCAVVGNSGTLLNSQYGDLIDKHEI
VIRLNNAKTERFEKKVGSKTNISFINSNILHQCGRRESCYCHPYGETVPIVMYICQPIHVLDYTLCKPSHRAPLLITDPRFDVMCARIVKYYSVKKFLEE
KKAKGFVDWSKDHEGSLFHYSSGMQAVMLAVGICEKVSVFGFGKLNSTKHHYHTNQKAELKLHDYEAEYRLYRDLENSPRAIPFLPKEFKIPLVQVYH*
>AT1G22015.1 | Symbols: GALT8, DD46 |  | chr1:7751225-7753425 REVERSE LENGTH=398
MKHNNKVSKRLTMTWVPLLCISCFFLGAIFTSKLRSASSDSGSQLILQHRRDQELKIVTQDYAHEKKKSQDNDVMEEVLKTHKAIESLDKSVSMLQKQLS
ATHSPQQIVNVSATNSSTEGNQKNKVFMVIGINTAFSSRKRRDSLRETWMPQGEKLEKLEKEKGIVVKFMIGHSSTPNSMLDKEIDSEDAQYNDFFRLDH
VEGYYNLSAKTKSFFSSAVAKWDAEFYVKIDDDVHVNLGTLASTLASHRSKPRVYIGCMKSGPVLTKKTAKYREPEFWKFGEEGNKYFRHATGQIYAISK
DLATYISNNQPILHKYANEDVTLGSWFIGLEVEQIDDRNFCCGTPPDCEMRAEAGEMCVATFDWKCSGVCRSVDRMWMVHVMCGEGSKAVWDANLKLS*
>AT1G26810.1 | Symbols: GALT1 | galactosyltransferase1 | chr1:9286862-9289327 REVERSE LENGTH=643
MKRFYGGLLVVSMCMFLTVYRYVDLNTPVEKPYITAAASVVVTPNTTLPMEWLRITLPDFMKEARNTQEAISGDDIAVVSGLFVEQNVSKEEREPLLTWN
RLESLVDNAQSLVNGVDAIKEAGIVWESLVSAVEAKKLVDVNENQTRKGKEELCPQFLSKMNATEADGSSLKLQIPCGLTQGSSITVIGIPDGLVGSFRI
DLTGQPLPGEPDPPIIVHYNVRLLGDKSTEDPVIVQNSWTASQDWGAEERCPKFDPDMNKKVDDLDECNKMVGGEINRTSSTSLQSNTSRGVPVAREASK
HEKYFPFKQGFLSVATLRVGTEGMQMTVDGKHITSFAFRDTLEPWLVSEIRITGDFRLISILASGLPTSEESEHVVDLEALKSPTLSPLRPLDLVIGVFS
TANNFKRRMAVRRTWMQYDDVRSGRVAVRFFVGLHKSPLVNLELWNEARTYGDVQLMPFVDYYSLISWKTLAICIFGTEVDSAKFIMKTDDDAFVRVDEV
LLSLSMTNNTRGLIYGLINSDSQPIRNPDSKWYISYEEWPEEKYPPWAHGPGYIVSRDIAESVGKLFKEGNLKMFKLEDVAMGIWIAELTKHGLEPHYEN
DGRIISDGCKDGYVVAHYQSPAEMTCLWRKYQETKRSLCCREW*
>AT1G27120.1 | Symbols: GALT4 |  | chr1:9421389-9423910 FORWARD LENGTH=673
MKKSKLDNSSSQIRFGLVQFLLVVLLFYFLCMSFEIPFIFRTGSGSGSDDVSSSSFADALPRPMVVGGGSREANWVVGEEEEADPHRHFKDPGRVQLRLP
ERKMREFKSVSEIFVNESFFDNGGFSDEFSIFHKTAKHAISMGRKMWDGLDSGLIKPDKAPVKTRIEKCPDMVSVSESEFVNRSRILVLPCGLTLGSHIT
VVATPHWAHVEKDGDKTAMVSQFMMELQGLKAVDGEDPPRILHFNPRIKGDWSGRPVIEQNTCYRMQWGSGLRCDGRESSDDEEYVDGEVKCERWKRDDD
DGGNNGDDFDESKKTWWLNRLMGRRKKMITHDWDYPFAEGKLFVLTLRAGMEGYHISVNGRHITSFPYRTGFVLEDATGLAVKGNIDVHSVYAASLPSTN
PSFAPQKHLEMQRIWKAPSLPQKPVELFIGILSAGNHFAERMAVRKSWMQQKLVRSSKVVARFFVALHARKEVNVDLKKEAEYFGDIVIVPYMDHYDLVV
LKTVAICEYGVNTVAAKYVMKCDDDTFVRVDAVIQEAEKVKGRESLYIGNINFNHKPLRTGKWAVTFEEWPEEYYPPYANGPGYILSYDVAKFIVDDFEQ
KRLRLFKMEDVSMGMWVEKFNETRPVAVVHSLKFCQFGCIEDYFTAHYQSPRQMICMWDKLQRLGKPQCCNMR*
>AT1G32930.1 | Symbols: AtGALT31A, GALT31A | glycosyltransferase of CAZY family GT31 A | chr1:11931980-11934399 REVERSE LENGTH=399
MGMGRYQKSATSGVSARWVFVLCISSFLLGVLVVNRLLASFETVDGIERASPEQNDQSRSLNPLVDCESKEGDILSRVSHTHDVIKTLDKTISSLEVELA
TARAARSDGRDGSPAVAKTVADQSKIRPRMFFVMGIMTAFSSRKRRDSIRGTWLPKGDELKRLETEKGIIMRFVIGHSSSPGGVLDHTIEAEEEQHKDFF
RLNHIEGYHELSSKTQIYFSSAVAKWDADFYIKVDDDVHVNLGMLGSTLARHRSKPRVYIGCMKSGPVLAQKGVKYHEPEYWKFGEEGNKYFRHATGQIY
AISKDLATYISVNRQLLHKYANEDVSLGSWFIGLDVEHIDDRSLCCGTPLDCEWKGQAGNPCAASFDWSCSGICKSVDRMLEVHQRCGEGDGAIWHSSF*
>AT1G33430.2 | Symbols: KNS4, UPEX1 | UNEVEN PATTERN OF EXINE1, KAONASHI 4 | chr1:12124438-12126052 REVERSE LENGTH=403
MRAKAASGKAIIVLCLASFLAGSLFMSRTLSRSYIPEEEDHHLTKHLSKHLEIQKDCDEHKRKLIESKSRDIIGEVSRTHQAVKSLERTMSTLEMELAAA
RTSDRSSEFWSERSAKNQSRLQKVFAVIGINTAFSSKKRRDSVRQTWMPTGEKLKKIEKEKGIVVRKFGFLFDRFVIGHSATPGGVLDKAIDEEDSEHKD
FLRLKHIEGYHQLSTKTRLYFSTATAMYDAEFYVKVDDDVHVNLGMLVTTLARYQSRPRIYIGCMKSGPVLSQKGVKYHEPEFWKFGEEGNKYFRHATGQ
IYAISKDLATYISTNQGILHRYANEDVSLGAWMLGLEVEHVDERSMCCGTPPDCQWKAQAGNVCAASFDWSCSGICKSVDRMARVHRACAEGDTPLANFR
FFV*
>AT1G53290.1 | Symbols: GALT9 |  | chr1:19871353-19873251 FORWARD LENGTH=345
MHSPRKLFHARSSLATRRSTALVVLTSLAIGIAGFTFGLAVILIPGLRLTGRNCLTNTPPKTVRVVWDVAGNSNGVVSGEKKRHKVMGFVGIQTGFGSAG
RRRSLRKTWMPSDPEGLRRLEESTGLAIRFMIGKTKSEEKMAQLRREIAEYDDFVLLDIEEEYSKLPYKTLAFFKAAYALYDSEFYVKADDDIYLRPDRL
SLLLAKERSHSQTYLGCLKKGPVFTDPKLKWYEPLSHLLGKEYFLHAYGPIYALSADVVASLVALKNNSFRMFNNEDVTIGAWMLAMNVNHENHHILCEP
ECSPSSVAVWDIPKCSGLCNPEKRMLELHKQESCSKSPTLPSDDE*
>AT1G74800.1 | Symbols: GALT5 | AGP galactosyltransferase5 | chr1:28102221-28104993 REVERSE LENGTH=672
MKKPKLSKVEKIDKIDLFSSLWKQRSVRVIMAIGFLYLVIVSVEIPLVFKSWSSSSVPLDALSRLEKLNNEQEPQVEIIPNPPLEPVSYPVSNPTIVTRT
DLVQNKVREHHRGVLSSLRFDSETFDPSSKDGSVELHKSAKEAWQLGRKLWKELESGRLEKLVEKPEKNKPDSCPHSVSLTGSEFMNRENKLMELPCGLT
LGSHITLVGRPRKAHPKEGDWSKLVSQFVIELQGLKTVEGEDPPRILHFNPRLKGDWSKKPVIEQNSCYRMQWGPAQRCEGWKSRDDEETVDSHVKCEKW
IRDDDNYSEGSRARWWLNRLIGRRKRVKVEWPFPFVEEKLFVLTLSAGLEGYHINVDGKHVTSFPYRTGFTLEDATGLTVNGDIDVHSVFVASLPTSHPS
FAPQRHLELSKRWQAPVVPDGPVEIFIGILSAGNHFSERMAVRKSWMQHVLITSAKVVARFFVALHGRKEVNVELKKEAEYFGDIVLVPYMDSYDLVVLK
TVAICEHGALAFSAKYIMKCDDDTFVKLGAVINEVKKVPEGRSLYIGNMNYYHKPLRGGKWAVTYEEWPEEDYPPYANGPGYVLSSDIARFIVDKFERHK
LRLFKMEDVSVGMWVEHFKNTTNPVDYRHSLRFCQFGCVENYYTAHYQSPRQMICLWDKLLRQNKPECCNMR*
>AT3G06440.1 | Symbols: GALT3 |  | chr3:1972913-1975272 REVERSE LENGTH=619
MKQFMSVVRFKFGFTSVRMRDWSVGVSIMVLTLIFIIRYEQSDHTHTVDDSSIEGESVHEPAKKPHFMTLEDLDYLFSNKSFFGEEEVSNGMLVWSRMRP
FLERPDALPETAQGIEEATLAMKGLVLEINREKRAYSSGMVSKEIRRICPDFVTAFDKDLSGLSHVLLELPCGLIEDSSITLVGIPDEHSSSFQIQLVGS
GLSGETRRPIILRYNVNFSKPSIVQNTWTEKLGWGNEERCQYHGSLKNHLVDELPLCNKQTGRIISEKSSNDDATMELSLSNANFPFLKGSPFTAALWFG
LEGFHMTINGRHETSFAYREKLEPWLVSAVKVSGGLKILSVLATRLPIPDDHASLIIEEKLKAPSLSGTRIELLVGVFSTGNNFKRRMALRRSWMQYEAV
RSGKVAVRFLIGLHTNEKVNLEMWRESKAYGDIQFMPFVDYYGLLSLKTVALCILGTKVIPAKYIMKTDDDAFVRIDELLSSLEERPSSALLYGLISFDS
SPDREQGSKWFIPKEEWPLDSYPPWAHGPGYIISHDIAKFVVKGHRQRDLGLFKLEDVAMGIWIQQFNQTIKRVKYINDKRFHNSDCKSNYILVHYQTPR
LILCLWEKLQKENQSICCE*
>AT4G21060.1 | Symbols: AtGALT2, GALT2 | AGP galactosyltransferase 2 | chr4:11240730-11244860 FORWARD LENGTH=741
MATSRLARFVSEVAPPQFVTVMRRHRAAKQKLDTIKEEENKEDSFNGGMVVMMKTSHQHTLLIFRSCRDLAAIVGFRILLFTGFSGFYLVFLAFKFPHFI
EMVAMLSGDTGLDGALSDTSLDVSLSGSLRNDMLNRKLEDEDHQSGPSTTQKVSPEEKINGSKQIQPLLFRYGRISGEVMRRRNRTIHMSPFERMADEAW
ILGSKAWEDVDKFEVDKINESASIFEGKVESCPSQISMNGDDLNKANRIMLLPCGLAAGSSITILGTPQYAHKESVPQRSRLTRSYGMVLVSQFMVELQG
LKTGDGEYPPKILHLNPRIKGDWNHRPVIEHNTCYRMQWGVAQRCDGTPSKKDADVLVDGFRRCEKWTQNDIIDMVDSKESKTTSWFKRFIGREQKPEVT
WSFPFAEGKVFVLTLRAGIDGFHINVGGRHVSSFPYRPGFTIEDATGLAVTGDVDIHSIHATSLSTSHPSFSPQKAIEFSSEWKAPPLPGTPFRLFMGVL
SATNHFSERMAVRKTWMQHPSIKSSDVVARFFVALNPRKEVNAMLKKEAEYFGDIVILPFMDRYELVVLKTIAICEFGVQNVTAPYIMKCDDDTFIRVES
ILKQIDGVSPEKSLYMGNLNLRHRPLRTGKWTVTWEEWPEAVYPPYANGPGYIISSNIAKYIVSQNSRHKLRLFKMEDVSMGLWVEQFNASMQPVEYSHS
WKFCQYGCTLNYYTAHYQSPSQMMCLWDNLLKGRPQCCNFR*
>AT5G53340.1 | Symbols: GALT7, HPGT1 | hydroxyproline O-galactosyltransferase 1 | chr5:21641045-21643195 REVERSE LENGTH=338
MARKGSSIRLSSSRISTLLLFMFATFASFYVAGRLWQESQTRVHLINELDRVTGQGKSAISVDDTLKIIACREQKKTLAALEMELSSARQEGFVSKSPKL
ADGTETKKRPLVVIGIMTSLGNKKKRDAVRQAWMGTGASLKKLESEKGVIARFVIGRSANKGDSMDKSIDTENSQTDDFIILDDVVEAPEEASKKVKLFF
AYAADRWDAQFYAKAIDNIYVNIDALGTTLAAHLENPRAYIGCMKSGEVFSEPNHKWYEPEWWKFGDKKAYFRHAYGEMYVITHALARFVSINRDILHSY
AHDDVSTGSWFVGLDVKHVDEGKFCCSAWSSEAICAGV*
>AT5G62620.1 | Symbols: GALT6 |  | chr5:25137136-25139764 FORWARD LENGTH=681
MRKPKLSKLERLEKFDIFVSLSKQRSVQILMAVGLLYMLLITFEIPFVFKTGLSSLSQDPLTRPEKHNSQRELQERRAPTRPLKSLLYQESQSESPAQGL
RRRTRILSSLRFDPETFNPSSKDGSVELHKSAKVAWEVGRKIWEELESGKTLKALEKEKKKKIEEHGTNSCSLSVSLTGSDLLKRGNIMELPCGLTLGSH
ITVVGKPRAAHSEKDPKISMLKEGDEAVKVSQFKLELQGLKAVEGEEPPRILHLNPRLKGDWSGKPVIEQNTCYRMQWGSAQRCEGWRSRDDEETVDGQV
KCEKWARDDSITSKEEESSKAASWWLSRLIGRSKKVTVEWPFPFTVDKLFVLTLSAGLEGYHVSVDGKHVTSFPYRTGFTLEDATGLTINGDIDVHSVFA
GSLPTSHPSFSPQRHLELSSNWQAPSLPDEQVDMFIGILSAGNHFAERMAVRRSWMQHKLVKSSKVVARFFVALHSRKEVNVELKKEAEFFGDIVIVPYM
DSYDLVVLKTVAICEYGAHQLAAKFIMKCDDDTFVQVDAVLSEAKKTPTDRSLYIGNINYYHKPLRQGKWSVTYEEWPEEDYPPYANGPGYILSNDISRF
IVKEFEKHKLRMFKMEDVSVGMWVEQFNNGTKPVDYIHSLRFCQFGCIENYLTAHYQSPRQMICLWDKLVLTGKPQCCNMR*
```
## 无法连上校园网怎么办
人不在学校，没有校园网VPN，也不想在TAIR注册怎么办？我们仍然有办法。点击Download All我们会得到一个tsv。可以用Excel打开，我们将发现第二列就是我们需要的基因ID。
```bash
AT1G53290
AT1G08280
AT1G74800
AT1G22015
AT5G62620
AT1G27120
AT3G06440
AT1G26810
AT5G53340
AT4G21060
AT1G32930
AT1G33430
```
我们可以在[Sequence Bulk Download](https://v2.arabidopsis.org/tools/bulk/sequences/index.jsp)里下载，一样会自动跳转到一个网页，复制全部序列，然后使用`vim`写入新文件中。

<img width="1440" height="705" alt="Image" src="https://github.com/user-attachments/assets/3759b73c-3352-4e17-987d-935caec19ca4" />

于是我们现在拥有了AtGALT蛋白质文件与PF01762的HMM Profile文件。

## 下载苹果（*Malus Domestica*）基因组文件
我们可以在[Ensembl Plants](https://plants.ensembl.org/info/data/ftp/index.html)里搜索Malus过滤出仅有的一个苹果基因组。这里我们需要DNA fasta、Protein fasta和Gene Sets的gff3。单击以后会进入一个页面，染色体选择toplevel，意思是全部染色体都在一个文件里，他们还会提供单个染色体的文件。

<img width="1198" height="251" alt="Image" src="https://github.com/user-attachments/assets/777e5fed-3589-4f24-866f-62947d7e2641" />

或者在[GDR](https://www.rosaceae.org/organism/24348?pane=bio_data_1_rsc_genomes)中选取一个合适的基因组也是不错的。如果文件名中带有haploid或diploid，选择单倍型haploid。GDR中的基因组多的眼花缭乱，我们任意选择一个其实不会对结果造成太大影响。

我们这次选择 GDR 的苹果基因组文件(Ensembl Plants的苹果基因组到后续分析会有些问题，所以我们不用，我为什么知道是因为我曾经用过感觉需要调整的地方很多)。
基因组版本为 (Malus x domestica Antonovka 172670-B Whole Genome v1.0 Assembly & Annotation)[https://www.rosaceae.org/Analysis/17808414]
```bash
wget https://www.rosaceae.org/rosaceae_downloads/Malus_x_domestica/Antonovka_172670-B_v1.0/assembly/Antonovka_hapolomeA.fa.gz
wget https://www.rosaceae.org/rosaceae_downloads/Malus_x_domestica/Antonovka_172670-B_v1.0/genes/Antonovka_hapolomeA_pep.fa.gz
wget https://www.rosaceae.org/rosaceae_downloads/Malus_x_domestica/Antonovka_172670-B_v1.0/genes/Antonovka_hapolomeA.gff3.gz
wget https://www.rosaceae.org/rosaceae_downloads/Malus_x_domestica/Antonovka_172670-B_v1.0/genes/Antonovka_hapolomeA_CDS.fa.gz

gzip -d *.gz

mv Antonovka_hapolomeA.gff3 md.gff3
mv Antonovka_hapolomeA.fa md.chr
mv Antonovka_hapolomeA_pep.fa md.pep
mv Antonovka_hapolomeA_CDS.fa md.cds
```
- `wget`：w指网络，也就是一个可以通过链接下载文件的本地的一个指令。
- `*`：代表任意长度的任意字符串，所以gzip -d *.gz的意思是把尾巴是.gz的全部文件都解压。
- `mv 文件1 名称2`：可以把文件1的名称改为名称2。

如果你想查看当前路径可以用`pwd`，如果想知道当前路径都有什么文件可以使用`ls`，或者更多变体比如`ls -l`、`ls -lah`。如果想看一个文件的内容可以使用`less md.gff3`，退出按`q`。
于是乎我们拥有了鉴定基因家族蛋白的全部文件了。我们还差什么呢？

## 我们还差软件
我们还需要2个十分重要的软件：
- `blast`
- `hmmer`
要想很方便的安装这些软件，我们有**本本分分安装法**与**一劳永逸法**。我们先看看一劳永逸法，因为绝大部分的软件都可以用这个方法，然后在看本本分分安装法，因为有些特殊的软件可能必须得自己安装。

### 一劳永逸之Anaconda
我们要下载一个叫做anaconda的东西，你可以把它理解为很多软件都能通过它安装。等我们安装好我们就可以通过`conda install`来安装我们需要的分析包。如果你学过python应该对`pip install`不陌生，它们都是用来安装包的，而且conda可以用来安装python。
你可以选择进入[anaconda](https://repo.anaconda.com/archive/)的下载网址，这里有非常非常多可以选择的。我们是为了安装在终端，所以选择后缀为.sh的。里面有MacOSX、Windows和Linux三种系统可以选择。
以MacOS为例，我们下载并执行：
```bash
wget https://repo.anaconda.com/archive/Anaconda3-2025.12-2-MacOSX-arm64.sh
bash Anaconda3-2025.12-2-MacOSX-arm64.sh
```
- anaconda有880.9M，请耐心等待
- wget是下载
- bash是运行以.sh为后缀的shell脚本
运行后你会看见：
```bash
Welcome to Anaconda3 2025.12-2

In order to continue the installation process, please review the license
agreement.
Please, press ENTER to continue
>>> 
```
长按Enter回车键（一般按两下也可以）直到：
```bash
Do you accept the license terms? [yes|no]
>>> 
```
输入yes：
```bash
Anaconda3 will now be installed into this location:
/Users/YourUserName/anaconda3

  - Press ENTER to confirm the location
  - Press CTRL-C to abort the installation
  - Or specify a different location below
>>> 
```
这里一般情况下是长按Enter即可，但是你也可以选择安装到其他地址，比如我就会安装到移动硬盘里`/Volumes/MyPSD/anaconda3`。

然后我们才正式进入到安装环节，自此我们把Anaconda3简称为conda。首先我们需要了解一个概念叫**环节配置**，我们经常会看到别人说配环境。如何通俗的理解？
环境的全称是“虚拟环境”，我们可以创建一个新环境，同时规定好python版本。我们可能同一道分析使用到的软件依赖于不同版本的python，有的是python3有的是python2，使用我们就需要一个python3的虚拟环境和一个python2的虚拟环境。环境像是软件运行必须的氛围，如果把人比作软件，环境就像是图书馆和操场，有人在操场才可以学习（我知道这个例子很奇葩），有人在图书馆才能学习。环境就是软件运行的条件。

我们可以这样子配置环境并激活与关闭环境：    （请一行一行复制，我的意思是不要点右边这个一键复制的按钮哦!）
```bash
conda create -n env1 python=3.9
conda activate env1
conda deactivte env1
```
- `create`是创建虚拟环境的指令
- `-n`是命名为，`env1`是环境名称，可以修改成别的
- `python=3.9`设定python版本为3.9（可以不加，就会使用默认的python版本），我当时默认是安装3.13.2
- `activate`是激活，`deactivate`是关闭

后期我们可能会用的一些软件是需要 Intel (x86) 版本的 Python 环境，我们可以创建一个：
```bash
CONDA_SUBDIR=osx-64 conda create -n x86env
conda activate x86env
conda config --env --set subdir osx-64
```
我们将使用`x86env`这个虚拟环境安装各种软件来做分析。如果出现了`CondaError: Run 'conda init' before 'conda activate'`就重启终端就好。
到这一步我们才开始真正安装我们需要的软件（遇到`Proceed ([y]/n)? `一概y）：
```bash
conda install -c bioconda blast
conda install -c bioconda hmmer
```
我们就安装好了！更多功能可详见`conda -h`或者`conda --help`。
接下来我们来看看本本分分安装法是怎么回事。
 
### 本本分分之什么软件都是这个法
#### BLAST+
进入[blast+](https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/)下载页面：
```bash
wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.17.0+-aarch64-macosx.tar.gz
tar -zxvf ncbi-blast-2.17.0+-aarch64-macosx.tar.gz
cd /ncbi-blast-2.17.0+/bin
```
进入`bin`我们就会发现需要的软件都在里面比如`blastn`、`blastp`、`blastx`、`tblastn`等等。
blast全称 Basic Local Alignment Search Tool，翻译为基本局部比对搜索工具，其功能是寻找从两个序列中找到最大的相似片段，它会用目标序列和数据库中的序列一一比对，按照参数过滤出最相似的一批序列。所以这些工具都是blast，他们的功能可以简单解释为：
- `blastn`：用核苷酸比对核苷酸库
- `blastp`：用蛋白质比对蛋白质库
- `blastx`：核苷酸翻译为蛋白质，再用蛋白质比对蛋白质库
- `tblastn`：核苷酸库翻译为蛋白质库，再用蛋白质比对蛋白质库

目前我们需要使用的是`blastp`，我们可以简单用`./ncbi-blast-2.17.0+/bin/blastp -h`查看使用方法。不过这会很麻烦每一次都要输入这么长的代码。
我们有办法少写点吗？包的包的：
第一步是`vim ~/.zshrc`（这些文件名前面带.的都会被隐藏起来），会出现
```bash
Swap file "~/.zshrc.swp" already exists!
[O]pen Read-Only, (E)dit anyway, (R)ecover, (D)elete it, (Q)uit, (A)bort: 
```
我们输入`e`即可，找一个空行，之前讲`vim`的时候我们提到过想输入要先按`i`，然后贴上：
```bash
export PATH="/Users/YourUserName/Desktop/GeneFamilyAnalysis/ncbi-blast-2.17.0+/bin:$PATH"
```
> 其中`/Users/YourUserName/Desktop/GeneFamilyAnalysis`是我们当时`wget`的路径，这个是每个人都不一样的。也是我们唯一需要自己修改的部分。

然后我们`:wq`退出后再`source ~/.zshrc`。我们就可以使用：
```bash
blastp -h
```
#### Hmmer
进入[Hmmer](http://hmmer.org/download.html)下载页面，具体如何安装看[Documentation](http://hmmer.org/documentation.html)：
```bash
wget http://eddylab.org/software/hmmer/hmmer-3.4.tar.gz
tar -zxvf hmmer-3.4.tar.gz
cd hmmer-3.4
./configure
make
make check
sudo make install
```
我想大家已经能感受到本本分分法的麻烦了。确实是麻烦，之后的包我们都用`conda install -c bioconda 软件名`安装。

## 开始鉴定基因家族蛋白
我们首先使用`hmmer`，因为这个最快，先检查是否可以使用`hmmsearch -h`。关于为什么是输入`hmmer`我也不清楚，不同软件的用法都有所差异，这个软件也不需要我们`source ~/.zshrc`。
```bash
hmmsearch --tblout hmm.res PF01762.hmm md.pep
less hmm.res
```
我们就能看到这个简简单单的表格，我们只需要第一列：
```bash
awk '{print $1}' hmm.res | grep -v '#' > hmm.id
```
- `awk`：一个按照列处理文本的工具
- `$1`：表示第一列
- `|`：表示下一步，也称作管道符，如果你接触过R语言，应该也见过`%>%`和`|>`
- `grep`：：一个按照行处理文本的工具，一行一行匹配信息
- `-v '#'`：不匹配符号`#`，也就是过滤掉注释行。如果是想匹配就去掉`-v`
- `>`：表示导出为，如果没有就会直接打印出来

然后我们使用`blastp`：
```bash
makeblastdb -in md.pep -input_type fasta -parse_seqids -dbtype prot -out md
blastp -task blastp -db md -query ath.galt.pep -evalue 10 -outfmt 6 -out blast.res
awk '{print $2}' blast.res > blast.id1
sort blast.id1 | uniq > blast.id
```
- `-query`：表示输入文件，query这个单词会经常出现，可以理解为“灰姑娘的水晶鞋”，在此也是我们的拟南芥GALT蛋白序列
- `-db md`：表示选择数据库，之前`makeblastdb`的时候`-out md`，所以蛋白质数据库的前缀都是`md`
- `-evalue 10`：表示1e-10，是一个很常用的e-value， e-value越小，筛选条件越严格，得到的序列数量就越少
- `-outfmt 6`：按照第6种格式表格输出，还有非常多不同的格式
- `sort`：表示排序
- `uniq`：表示去重复

可能会有同学问到，为什么已经是`blastp`了，还需要注明`-task blastp`，这不是多此一举吗？有这样的疑问是很好的，我也思考过为什么。答案就在`blastp -help`里，我们会看到：
```bash
*** General search options
 -task <String, Permissible values: 'blastp' 'blastp-fast' 'blastp-short' >
   Task to execute
   Default = `blastp'
```
如果我们不使用其他变体，那默认就是`-task blastp`，其实也可以不注明。这里是希望大家哪怕在复制粘贴的时候也要保持好奇心，感到奇怪就提出问题并寻找答案。所以以上的一些部分其实可以省略，有默认数值。
可能会有同学还会问到，为什么`hmm.id`不用去重复，而`blastp`需要。因为同一个苹果的蛋白质可能被多个AtGALT选中，毕竟是基因家族，蛋白质之间都非常相似，所以我们要去重复。

自此我们拥有了`hmm.id`和`blast.id`，我们取二者交集就是我们的基因家族蛋白候选成员了，注意这里我们的描述是**候选成员**。
```bash
grep -Fxf blast.id hmm.id > md.id
```
我们可以用这一份蛋白质ID来提取序列了。需要一个新软件叫`seqkit`：
```bash
conda install -c bioconda seqkit
seqkit grep -f md.id md.pep -o md.galt.pep
```
如果你想简单查看某一个蛋白质的序列，比如ANT15A011410.1，可以使用`seqkit grep -p "ANT15A011410.1" md.pep`会打印出来。
**恭喜大家，我们已经初步筛选出苹果GALT基因家族的候选蛋白了！！！**

## 保守结构域预测
完成这一步我们才能说真的确定这些蛋白质是基因家族蛋白而非候选蛋白。需要使用[Batch CD-Search](https://www.ncbi.nlm.nih.gov/Structure/bwrpsb/bwrpsb.cgi)或者[SMART](https://smart.embl.de/)。但是SMART在网页端不能进行批量检测，只能一条一条检测。虽然它们提供了一份perl脚本，但是很容易报错，需要额外安装很多包。目前来看是没必要使用这个脚本的。
我们将`md.galt.pep`上传后按照默认选项下载文件即可，后续会用到这个文件。默认文件名是`hitdata.txt`。
<img width="1229" height="659" alt="截屏2026-03-03 上午2 36 06" src="https://github.com/user-attachments/assets/5b0dce1e-d234-4f37-99e8-c4c0d337b23c" />

我们注意到Galactosyl_T肯定是我们要的结构域，但PLN03193是什么？看起来很重要因为每一个蛋白质都有这个结构域。我们可以直接去NCBI里搜索，[结果在这](https://www.ncbi.nlm.nih.gov/Structure/cdd/cddsrv.cgi?uid=178735)：

非常让人舒心，描述为“beta-1,3-galactosyltransferase; Provisional”，来自文章 Identification of a novel group of putative Arabidopsis thaliana beta-(1,3)-galactosyltransferases.Plant Mol Biol 2008 Sep ; 68(1-2):43-59

**自此我们可以宣布我们找到了全部可能的苹果GALT基因家族蛋白。**

## 你可曾想过写个脚本批量获取不同物种的GALTs
这是一个很有挑战的想法，说明你很想了解shell脚本是这么回事，我们安装Anaconda下载的文件就是一个巨大的shell脚本。不过我们会写一个很小很小的shell脚本。
那我们就定8个物种来做做吧～比如：拟南芥、苹果、梨、橙子、葡萄、草莓、桃子、番茄。
所有需要的文件都放在了`identification.zip`中，具体运行代码如下：
```bash
wget https://raw.githubusercontent.com/samcaimingzhe/Learning-Linux-by-Gene-Family-Bioinformatics-Analysis/main/identificaition.zip
unzip identificaition.zip
cd identification
bash download_and_process_data.sh
bash extract_family_proteins.sh
```
你们可以自己`less 文件名`观察观察里面写了些什么，如果有更多时间的话。
建议先运行一下哦，把这个跑通。因为我们下一个分析需要用到生成的`Merged.galt.simplified.pep`。

# 一些迷思
你问我有可能遗漏吗？是有可能的，但这种遗漏是技术的结构性问题。

到此我们休息一下，不妨思考冷静下来思考一下，我们是如何证明AtGALT和MdGALT都是一个家族的蛋白质。我们是从蛋白质序列的相似性出发的。序列相似是功能相似的什么条件？高中数学的充分必要条件，是哪一种？

**必要不充分条件**，功能相似的序列通常长得很像，但长得像的序列功能不一定一样。

是否存在一些蛋白质变异的可能已经让我吗无法筛选出来，缺又默默行使着它们的生物学功能，也许吧，也许是存在的，虽然可能性很小，我们学高等数学的时候就知道“概率为0的事件也有可能发生”。这世界千千万万，总有我们抓不住的东西。生物信息学只是一套分析法，其目的本身就是为生物学带来计算机给人类的一大优势——效率。

等我们做到后面就会发现，可能我们发现了20个甚至200个有潜在价值的蛋白质，一做转录组分析看表达量就会大发现。根本没啥表达量，我们就会着重关注表达量高的家族成员。会进一步筛选出更加有分析价值的成员。最后我们很可能只会锁定个位数个成员做qPCR。

所以我们做的家族分析本质上就是一套流程化的分析法。在此仅产生一些小小的思考足矣。

# 构建系统发育进化树
我们需要另一个软件是`clustalw`，这个软件可以进行多序列比对与构建系统发育进化树。
## 多序列比对
```bash
conda install -c bioconda clustalw
mkdir phylogeny
```
`clustalw`的玩法和刚刚的软件不一样，不是一行一行运行的。我们只用输入`clustalw`然后回车。
```bash
 **************************************************************
 ******** CLUSTAL 2.1 Multiple Sequence Alignments  ********
 **************************************************************

     1. Sequence Input From Disc
     2. Multiple Alignments
     3. Profile / Structure Alignments
     4. Phylogenetic trees

     S. Execute a system command
     H. HELP
     X. EXIT (leave program)

Your choice: 
```
我们先使用`1.`，然后输入`result/Merged.galt.simplified.pep`。回车后会返回原来的界面，再输入`2.`会进入这个界面再输入`1.`：
```bash
****** MULTIPLE ALIGNMENT MENU ******

    1.  Do complete multiple alignment now Slow/Accurate
    2.  Produce guide tree file only
    3.  Do alignment using old guide tree file

    4.  Toggle Slow/Fast pairwise alignments = SLOW

    5.  Pairwise alignment parameters
    6.  Multiple alignment parameters

    7.  Reset gaps before alignment? = OFF
    8.  Toggle screen display          = ON
    9.  Output format options
    I. Iteration = NONE

    S.  Execute a system command
    H.  HELP
    or press [RETURN] to go back to main menu

Your choice: 
```
然后继续回车就好了，会有默认命名的文件生成。但是我们也可以修改文件名，比如从`result/Merged.galt.simplified.dnd`改为`phylogeny/Merged.galt.simplified.dnd`。
```bash
Enter a name for the CLUSTAL output file  [result/Merged.galt.simplified.aln]: phylogeny/Merged.galt.simplified.aln
Enter a name for the CLUSTAL output file  [result/Merged.galt.simplified.dnd]: phylogeny/Merged.galt.simplified.dnd
```
## 系统发育进化树
跑完之后就多次输入`x`退出到最初的界面，输入`4.`，然后输入`5.`：
```bash
Enter name for bootstrap output file   [result/Merged.galt.simplified.phb]: phylogeny/Merged.galt.simplified.phb
Enter seed no. for random number generator  (1..1000)    [111]: 79
Enter number of bootstrap trials  (1..10000)    [1000]: 1000
```
可以选择你喜欢的数字作为随机种子，或者直接回车（默认111）。Bootstrap一般使用1000即可。其默认使用的是NJ法（Neighbor-Joining）建树，这个信息在写论文的时候需要提及。
自此我们获得了进化树文件`Merged.galt.simplified.phb`。我们可以暂时离开终端，我们需要去画图了。
我们需要来到[ITOL（Interactive Tree Of Life）](https://itol.embl.de/)。

整个操作流程详见[Bilibili：都2024年了，如何快速入门基因家族分析？| ITOL美化系统进化树](https://www.bilibili.com/video/BV1va2VYHEre/?spm_id_from=333.1387.homepage.video_card.click)。
这是我2024年发布的，当时使用的树和我们现在做出来的不一样。所以大家可以自己尝试着去给树分亚家族。

<img width="4862" height="4742" alt="orMz5-6sutw2-o-CnvCvLg" src="https://github.com/user-attachments/assets/b3cceea8-e044-4552-a0fb-f21300a97a14" />

我们先简单观察一下树形，红色箭头指向的是3个影响树形分组的序列。由于ANT开头的是苹果GALT，我们不能去除这一条，我们可以在Soly和Cs两条中选择一条来去除，可以优先去除`Csi09G015180.1`。以及我们观察这个序列右边出现的`Csi09G023800.1,.2,.3,.4`这些都是同一个基因的剪切本，我们一般只取最长的`Csi09G023800.1`。这个在介绍gff3文件的时候有提及。

所以我们需要对`Merged.galt.simplified.pep`进行序列ID的提取。这一部分可能需要手动去除，因为不是所有序列的命名格式都是`.1.2.3.4`这样子。
```bash
cp result/Merged.galt.simplified.pep phylogeny
cd phylogeny
grep '>' Merged.galt.simplified.pep | sed 's/>//' > Merged.galt.id
cat Merged.galt.id
```
- `cp`：表示复制
- `sed 's/>//'`：表示把本行的`>`字符替换为空
- `cat`：可以打印出文件全部内容

我们会发现这个多剪切本的情况只出现在Cs中，因为序列不多我们可以自己手动删除。这里我贴上删除好的，大家可以自行`vim`一个新的`Merged.galt.id.1`，可以用Excel打开，也可以先`cp Merged.galt.id Merged.galt.id.1`后再删除里面个别剪切本，每一次修改文件都`cp`一份备份，这是一个需要养成的好习惯：
```bash

```

