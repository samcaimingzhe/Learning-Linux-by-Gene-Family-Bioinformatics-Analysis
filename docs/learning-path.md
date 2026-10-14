# 学习路线与章节索引

[返回项目首页](../README.md) · [文件说明](usage.md) · [已知问题](known-issues.md)

建议第一次学习时顺序阅读完整教程；已有分析经验的读者可以按阶段跳转。下列链接使用教程中的固定锚点。

| 顺序 | 教程入口 | 重点与阶段产物 |
| --- | --- | --- |
| 1 | [文件与数据库](../A_Tutorial_For_Linux_Learning.md#data-basics) | 理解 FASTA / GFF3，确定参考物种与数据来源 |
| 2 | [确定案例与准备材料](../A_Tutorial_For_Linux_Learning.md#case-study) | 准备 GALT 参考蛋白、HMM 模型及目标物种数据 |
| 3 | [安装软件](../A_Tutorial_For_Linux_Learning.md#software-setup) | 学习环境管理及软件安装，按自己的操作系统选择安装文件 |
| 4 | [候选蛋白鉴定](../A_Tutorial_For_Linux_Learning.md#family-identification) | 理解 HMM、BLAST、ID 提取与序列筛选 |
| 5 | [批量分析](../A_Tutorial_For_Linux_Learning.md#batch-identification) | 理解循环与多物种文件命名；先阅读运行限制 |
| 6 | [系统发育分析](../A_Tutorial_For_Linux_Learning.md#phylogeny) | 多序列比对、建树、筛选剪接本及 ID 重命名 |
| 7 | [Motif、结构域与基因结构](../A_Tutorial_For_Linux_Learning.md#gene-structure) | 准备 MEME、结构域、基因位置和树文件，绘制组合图 |
| 8 | [蛋白理化性质](../A_Tutorial_For_Linux_Learning.md#protein-properties) | 从蛋白 FASTA 生成性质表 |
| 9 | [亚细胞定位](../A_Tutorial_For_Linux_Learning.md#localization) | 使用在线工具获取预测结果 |
| 10 | [顺式作用元件](../A_Tutorial_For_Linux_Learning.md#cis-elements) | 已有启动子提取示例，后续内容待补充 |
| 11 | [表达数据利用](../A_Tutorial_For_Linux_Learning.md#expression) | 学习跨参考基因组 ID 匹配与表达热图示例 |
| 12 | [共线性分析](../A_Tutorial_For_Linux_Learning.md#collinearity) | 尚未完成，脚本和配置仅供进一步整理 |
| 13 | [参考文献](../A_Tutorial_For_Linux_Learning.md#references) | 查找教程列出的工具论文 |

## 学习时如何记录

每完成一个阶段，记录使用的软件版本、数据下载日期与版本、运行目录、命令和输出文件。示例 ID 表对应本教程的特定数据，不应直接用于不同基因组版本或不同基因家族。

先理解单物种的输入与输出，再扩展到批处理；先确认序列 ID 在不同文件中一致，再进入绘图阶段。
