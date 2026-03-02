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
- Genome Database for Rosaceae (GDR)：蔷薇科植物 https://www.rosaceae.org/
- Citrus Genome Database (CGD)：柑橘属植物 https://www.citrusgenomedb.org/
- Pear Mutiomic Database (PearMODB)：梨属植物 https://pearomics.njau.edu.cn/
- Pear Genomic Database (PGDB)：梨属植物 http://pyrusgdb.sdau.edu.cn/
- GrapeGenomics：葡萄科植物 https://www.grapegenomics.com/
- Grapedia：葡萄科植物 https://grapedia.org/genomes/
- Rice Genome Annotation Project：水稻 https://rice.uga.edu/
- Sol Genomic Network：茄科植物 https://solgenomics.net/
- International Wheat Genome Sequencing Consortium (IWGSC)：小麦 https://www.wheatgenome.org/

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


找到pfam号后点击进入网页，点击左边的Profile HMM，看到中间的Download继续点击。我们所需的Profile HMM文件就下载下来了，格式为压缩包gz。可以双击解压，如果你有安装相关的解压软件。或者进入终端：

> 我们要开始了解Linux command了！

```bash
cd ~/Desktop
mkdir GeneFamilyAnalysis
cd GeneFamilyAnalysis
mv ~/Downloads/PF01762.hmm.gz ~/Desktop/GeneFamilyAnalysis
gzip -d PF01762.hmm.gz
```
- cd是change directory，我们想到达哪个文件夹就需要对应的路径。
- mkdir是make directory，新建一个文件夹。
- mv是move，把文件移动到其他路径。
- gzip是压缩文件为gz压缩包的工具，-d是使用解压功能，这会把PF01762.hmm.gz解压为PF01762.hmm。

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
我们会进入这个文件，点击键盘 **i键**，代表insert，我们会看到终端左下角出现了**-- INSERT --**，这说明我们可以写入，我们把公共复制的fasta文本粘贴完后点击键盘 **esc键**，然后输入**:wq**，代表write和quit。这样子我们就写入好一个at.galt.pep了。
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
## 没有校园网
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
我们可以在[Sequence Bulk Download](https://v2.arabidopsis.org/tools/bulk/sequences/index.jsp)里下载，一样会自动跳转到一个网页，复制全部序列，然后使用vim写入新文件中。

<img width="1440" height="705" alt="Image" src="https://github.com/user-attachments/assets/3759b73c-3352-4e17-987d-935caec19ca4" />

于是我们现在拥有了AtGALT蛋白质文件与PF01762的HMM Profile文件。

# 下载苹果（*Malus Domestica*）基因组文件
我们可以在[Ensembl Plants](https://plants.ensembl.org/info/data/ftp/index.html)里搜索Malus过滤出仅有的一个苹果基因组。这里我们需要DNA fasta、Protein fasta和Gene Sets的gff3。单击以后会进入一个页面，染色体选择toplevel，意思是全部染色体都在一个文件里，他们还会提供单个染色体的文件。

<img width="1198" height="251" alt="Image" src="https://github.com/user-attachments/assets/777e5fed-3589-4f24-866f-62947d7e2641" />

或者在[GDR](https://www.rosaceae.org/organism/24348?pane=bio_data_1_rsc_genomes)中选取一个合适的基因组也是不错的。如果文件名中带有haploid或diploid，选择单倍型haploid。GDR中的基因组多的眼花缭乱，我们任意选择一个其实不会对结果造成太大影响。

我们这次选择Ensembl Plants的苹果基因组文件。
```bash
wget https://ftp.ebi.ac.uk/ensemblgenomes/pub/release-62/plants/fasta/malus_domestica_golden/dna/Malus_domestica_golden.ASM211411v1.dna.toplevel.fa.gz
wget https://ftp.ebi.ac.uk/ensemblgenomes/pub/release-62/plants/fasta/malus_domestica_golden/pep/Malus_domestica_golden.ASM211411v1.pep.all.fa.gz
wget https://ftp.ebi.ac.uk/ensemblgenomes/pub/release-62/plants/gff3/malus_domestica_golden/Malus_domestica_golden.ASM211411v1.62.chr.gff3.gz

gzip -d *.gz

mv Malus_domestica_golden.ASM211411v1.62.chr.gff3 md.gff3
mv Malus_domestica_golden.ASM211411v1.dna.toplevel.fa md.chr
mv Malus_domestica_golden.ASM211411v1.pep.all.fa md.pep
```
- wget的w指网络，也就是一个可以通过链接下载文件的本地的一个指令。
- *代表任意长度的任意字符串，所以gzip -d *.gz的意思是把尾巴是.gz的全部文件都解压。
- mv 文件1 名称2 可以把文件1的名称改为名称2。

于是乎我们拥有了鉴定基因家族蛋白的全部文件了。我们还差什么呢？

# 我们还差软件
我们还需要2个十分重要的软件：
- blast+
- hmmsearch
要想很方便的安装这些软件，我们有**本本分分安装法**与**一劳永逸法**。我们先看看一劳永逸法，因为绝大部分的软件都可以用这个方法，然后在看本本分分安装法，因为有些特殊的软件可能必须得自己安装。

## 一劳永逸之Anaconda
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
conda init x86env
conda activate x86env
conda config --env --set subdir osx-64
```
我们将使用`x86env`这个虚拟环境安装各种软件来做分析。
到这一步我们才开始真正安装我们需要的软件：
```bash
conda install -c bioconda blast+
conda install -c bioconda hmmsearch
```
 
## 传统办法
进入[blast+](https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/)下载页面：
```bash
wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.17.0+-aarch64-macosx.tar.gz
tar -zxvf ncbi-blast-2.17.0+-aarch64-macosx.tar.gz
```

