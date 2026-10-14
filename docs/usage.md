# 文件说明与运行约定

[返回项目首页](../README.md) · [学习路线](learning-path.md) · [已知问题](known-issues.md)

## 准备分析工作目录

仓库目录用于保存教程和脚本，分析工作目录用于保存下载数据与运行结果。脚本里的相对路径以终端当前目录为准，不以脚本所在目录为准。

下面的命令从克隆后的仓库根目录执行，只准备参考文件和目录，不下载基因组或运行分析：

```bash
REPO_DIR="$(pwd)"
mkdir -p work/identification/{proteins,annotations,chromosomes,result,databases}
cp data/reference/PF01762.hmm work/identification/
cp data/reference/ath.galt.pep work/identification/proteins/
cp config/file_url.txt work/identification/
cd work/identification
```

`REPO_DIR` 只在当前终端会话有效；打开新终端后，应将它设为仓库的实际绝对路径。

根据下载清单和教程准备各物种文件，采用以下命名：

| 目录 | 文件示例 | 用途 |
| --- | --- | --- |
| `proteins/` | `md.all.pep` | 目标物种全部蛋白序列 |
| `proteins/` | `ath.galt.pep` | 本教程的拟南芥 GALT 查询序列 |
| `annotations/` | `md.gff3` | 对应版本的基因注释 |
| `chromosomes/` | `md.chr` | 对应版本的基因组序列 |
| 当前目录 | `PF01762.hmm` | 本教程的 HMM 模型 |

原下载脚本有尚待修正的问题，暂不作为一键启动入口；详见[已知问题](known-issues.md)。准备好数据和依赖后，可在上述工作目录运行：

```bash
bash "$REPO_DIR/scripts/shell/extract_family_proteins.sh"
```

注意：现有鉴定脚本最后包含 `rm *.zip`，会删除当前工作目录中的 ZIP 文件。运行前请检查该目录，勿在存放待保留压缩包的目录运行。此处记录原有行为，整理版本未改动分析脚本。

主要结果位于 `result/`：每个物种的搜索结果、候选 ID、蛋白 FASTA，以及合并文件 `Merged.galt.simplified.pep`。这是候选集合，后续仍需按教程进行结构域检查及人工筛选。

## 脚本索引

| 脚本 | 输入及工作目录要求 | 输出或作用 |
| --- | --- | --- |
| [download_and_process_data.sh](../scripts/shell/download_and_process_data.sh) | 当前目录的 `file_url.txt`；需要 wget、gzip、tar 等命令 | 下载、解压并按硬编码名称归档；存在已知问题 |
| [extract_family_proteins.sh](../scripts/shell/extract_family_proteins.sh) | 上述目录；HMMER、BLAST+、SeqKit 和 Shell 文本处理工具 | HMM / BLAST 候选交集及合并蛋白序列 |
| [prot_analyzer.py](../scripts/python/prot_analyzer.py) | 第一个参数为蛋白 FASTA；依赖 Biopython | 标准输出为制表符分隔的性质表，错误信息写入标准错误 |
| [transform_gff_len.py](../scripts/python/transform_gff_len.py) | 三个参数依次为输入 GFF、输出 GFF 表、输出长度表；依赖 pandas | 用于共线性分析的转换草稿，ID 和排序逻辑需要复核 |
| [cd_motif_gene_1.0.R](../scripts/r/cd_motif_gene_1.0.R) | 当前绘图目录中的 MEME、基因位置、重命名表、结构域及树文件 | 基础版组合图与单图 |
| [cd_motif_gene_2.0.R](../scripts/r/cd_motif_gene_2.0.R) | 同上；额外使用脚本顶部的 Motif 和结构域筛选列表 | 筛选后的组合图与单图 |
| [col2circos.R](../scripts/r/col2circos.R) | 当前目录中的 `md.wgdi.gff` 和 `md.md.colgenes`；依赖 tidyverse | 当前目录的 `for_circos.txt` |

Python 性质分析示例（从实际分析目录执行，并替换输入路径）：

```bash
python3 -m pip install biopython
python3 "$REPO_DIR/scripts/python/prot_analyzer.py" input.pep > protein_report.tsv
```

R 绘图所需文件为 `meme.xml`、`Md.galt.cds.pos`、`Md.galt.mrna.pos`、`rename.id`、`cd.info`、`Md.renamed.galt.phb`。在包含这些文件的目录执行 `Rscript "$REPO_DIR/scripts/r/cd_motif_gene_2.0.R"`。脚本会尝试安装缺失的 R 包，其中 `ggmotif_0.2.1.tar.gz` 需要额外准备，仓库不包含该包。

## 数据与配置索引

| 文件 | 说明 |
| --- | --- |
| [PF01762.hmm](../data/reference/PF01762.hmm) | 教程所用 Galactosyl_T HMM 模型；文件头记录版本 |
| [ath.galt.pep](../data/reference/ath.galt.pep) | 教程所用拟南芥参考蛋白 |
| [示例数据目录](../data/examples/) | 三轮筛选 ID、`rename.id` 重命名表及 `hitdata.txt` 结构域结果 |
| [file_url.txt](../config/file_url.txt) | 原始下载清单，包含分组注释和空行 |
| [collinearity.conf](../config/collinearity.conf) | 共线性配置模板，路径字段需自行替换 |
| [identification.zip](../identification.zip) | 旧版示例快照，含原脚本及 macOS 元数据；保留用于对照 |

## 路径迁移说明

原根目录下的 `.sh`、`.py`、`.R` 文件分别移入 `scripts/shell/`、`scripts/python/`、`scripts/r/`；参考序列与模型移入 `data/reference/`；示例结果移入 `data/examples/`；下载清单和共线性配置移入 `config/`。

README、完整教程及旧压缩包继续位于根目录。教程中对应的 GitHub raw 下载路径已随文件位置调整；这些新网址需要在整理版本发布到 GitHub 后才会生效，本地使用可直接从上述目录复制文件。
