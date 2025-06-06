# RandNLA 

本仓库完成了2025春“矩阵分析与应用”课程作业中的“随机数值线性代数”课题。

## 文件结构

为引用方便，所有文件放在根目录./RandNLA中，并以文件名区分不同的文件性质和功能。本节仅对每个文件做概述，具体的实现细节请参照本文档的下一章。

- 后缀为.m的文件：完成课题子任务的函数模块。函数名下的注释简要描述了输入和输出。

  - ---

  - **采样任务是其他任务的基础。推荐先阅读这一部分的文档和代码。**

  - RandomSampling.m：完成随机采样任务。由于实现了多种采样方式，我们定义RandomSampling.m作为统一的采样函数，它接收一个matlab函数句柄"Sampler"作为参数（类似C++中的函数指针，要获取某名称为foo函数的句柄，方式为f=@foo）。Sampler可指定为任意一个名称中带有”Sampler"字样的函数的句柄，用于指定具体的采样方式。

  - GaussianSampler.m: 高斯随机采样。见[1]的II节定理1。

  - FastJLSampler.m: 快速JL采样，基于变换域方法。见[1]的II.B节。

  - LeverageSampler.m:杠杆值采样。一种重要度采样，保留被采样矩阵中影响较大的部分。见[1]的II.D节。

  - SparseSymbolSampler.m: 稀疏符号采样。见[1]的II.A节。

  - SparseEmbeddingSampler.m: [2]中提出的一种采样方法，应用于杠杆值的估计，也可以作为一种随机采样方式。见[2], p17。

  - ---

  - RandMatMul.m: 随机矩阵乘法见[1]的V节。进行随机矩阵乘法时需要对两个被乘矩阵进行行和列的采样，采样概率可以任意指定。RandMatMul.m中指定该概率分布为均匀分布。

  - LeverageMatMul.m: 先行估计第二个矩阵B的行杠杆值，以此为基础进行重要度采样。由[3]的表1，这样可以降低随机矩阵乘法结果的方差。

  - ---

  - 随机低秩逼近首先要估计待逼近矩阵**A**的列空间。因此首先实现两个列空间基选取算法。有关内容见[1]的IV.A节。

  - IterativeRangeFinder.m：迭代地选取**A**列空间的基，直到**A**落在选取的基之外的能量小于阈值。见[1]算法3。

  - RandRangeFinder.m：基于二分法确定选取列空间基的数目。

  - RandomSVD.m：随机SVD分解，见[1]IV.B节。

  - RandID.m：随机插值分解。关于插值分解的思想见[1]的IV.C节；具体实现见本文档下一节。

  - ---

    IterativeLS.m：迭代计算最小二乘，逐步减小残差。见[1]的III.A节。

  - PreconditionLS.m：利用随机分解的结果对**A**进行预处理以加快最小二乘计算的收敛速度。

- 后缀为.mlx的文件：

  - sampling_testbench.mlx：对采样算法进行验证。
  - matmul_testbench.mlx：对随机矩阵乘法进行验证。
  - lowrank_testbench.mlx：对SVD分解和低秩逼近进行验证。
  - LS_testbench.mlx：对随机最小二乘进行验证。


## 实现细节

本节描述各代码文件的实现细节。若文件对应未出现在文献上的算法，则给出详细的算法步骤；若文件对应的算法已经文献详述，则于此部分省略。

- RandomSampling：注意对某一矩阵A进行列采样可基于行采样完成：先对A的转置行采样再对结果转置。

- FastJLSampler：由于matlab中实现hadamard变换的fwht()函数效率非常慢，我们使用离散余弦变换代替之。其复杂度正比于mnlogm，m和n分别为输入矩阵A的行和列数，而与采样规模无关。（Hadamard变换的速度理论上快于离散余弦变换，故若有一hadamard变换的高效实现，其效率将比目前高）

- LeverageSampler：

  - 先估计杠杆值，再进行重要度采样。该算法见于[2],p30，我们固定了[2]给出算法中的r和t，分别为A列数的2倍和1/2。另外，[2]中的算法无法保证估计的各行重要度q之和为1，因此我们对q进行了归一化。
  - 中间矩阵R求逆的理论复杂度是O(n^2)，但如果自行编写针对上三角矩阵的求逆，效率反而劣于matlab自带的求逆，因此不做特殊处理。

- SparseSymbolSampler：[4]的9.2节给出该算法的描述，然而其似乎错误地计算了归一化因子。我们采用[4]中推荐的采样密度设置，但修正了归一化因子。

- LeverageMatMul：估计杠杆值并对A*B中的B进行行重要度采样。涉及杠杆值估计的部分和LeverageSampler是完全相同的。

- IterativeRangeFinder：

  - 采用了[5],p243的算法，但有所修正：由于算法13行已经对矩阵Y的j+1~j+r行相对于已经获得的列正交矩阵Q进行了正交化，第7行的正交化是不必要的。在[1]中对应的章节（算法3）也删去了这一步骤。此外，为避免反复分配内存影响效率，这一模块中针对矩阵Q和Y采用了先开辟大内存再移动数据指针的策略。
  - [5]中，每次迭代都要重新计算一次随机向量w和矩阵A的乘积。在算法实现时，我们可以直接对A进行高斯采样以准备足够多这样的乘积；而高斯采样又可以替换为FastJLSampler以节省效率。因此，我们直接将Y初始化为对A进行快速JL采样的结果。

- RandRangeFinder: 与上一模块类似，其目的在于找到合适的采样规模k，以使k>rank(A)但尽量小。其策略为：

  - 设置初始采样规模区间为[kmin, kmax]；
  - 设置k初值为kmin；
  - 用[4] 12.1节的随机估计方法估计A落在目前的列空间矩阵Q列空间之外的能量，若超过阈值，调整k为(k+kmax)/2，调整区间为[k, kmax]；若小于阈值则(k+kmin)/2，调整区间为[kmin, k]。
  - 当区间长度足够小，终止算法。

- RandomSVD：与RandomSampling类似，接收一个句柄参数用来指定列空间选取方法。

- RandID：插值分解（对列）核心在于找出A中较重要的列的集合。采用如下算法：

  - 对A进行随机采样得到Y=SA（原因见[1]，以下部分思想来源于[3],p60的5-8行）
  - 选定Y的第一列作为Q的第一列并归一化；
  - 每轮迭代中，将Y中的列投影到Q（Q的最后一列记为q）上，将残余能量最大的列选入Q并归一化，将此列从Y中移除。
  - 为降低复杂度，每次迭代中，只将Y投影到q对应子空间的正交补上，就可计算Y在Q列空间上的投影。
  - 如此采样k次，k为预先指定的列规模。
  - 代码中，Y_remain为本轮移除残余能量最大的列后，矩阵Y中剩余的部分；remain_index_table则维护Y中剩余部分（即Y_remain)的列在原矩阵Y中的下标。selected_index则指某一轮被选中的列向量在Y_remain中的下标，而非在原矩阵Y中的下标。
  - 插值矩阵X通过对A左乘C的伪逆获得。

- IterativeLS: 迭代求解最小二乘问题中涉及二次规划问题，采用quadprog()函数求解。

- ---

  以下介绍用于验证的各.mlx文件的内容。

- sampling_testbench：固定待采样矩阵规模m和n，调整采样规模k，计时比较几种采样算法的时间复杂度；同时随机产生试验向量x，统计|SAx|/|Ax|以计算嵌入精度（嵌入精度定义见[1] II节）。分别在稀疏和稠密两种情况下进行测试。

- matmul_testbench：变更Monte Carlo试验次数n和采样规模k，计算随机矩阵相乘结果的均方误差，并比较两种矩阵相乘方式的时间复杂度。设置左侧矩阵A是稠密的，右侧矩阵B有稀疏或稠密两种情况。

- lowrank_testbench：第一部分计算SVD分解的精度，以奇异值分布衡量；同时计时比较三种SVD分解的效率（两种随机，一种matlab自带的svd函数；svds有时不收敛故未加入测试）。第二部分计算两种低秩逼近的效果，以误差的Frobenius范数作为评价标准（值得注意的是，尽管ID可能性能较差，但其分解得到的结果具有实际的物理意义，因此仍然是有意义的算法）测例的奇异值设置为高斯分布，这样可以控制其虽然列满秩但是奇异的，可以在一定精度范围内用低秩矩阵逼近。

- LS_testbench：对比4种方式（2种随机，1种确定性迭代方法lsqr，1种伪逆求解）的时间复杂度。计算随机方法准确性时，以相对误差为标准，以伪逆求解的结果作为真值。测例为随机产生的矩阵A和向量b，为引入奇异性，在A的不同列上加上了不同的权重。

- ---

  此外，在所有需要采样且任意采样方式均可行的场合，均调用RandomSampling函数并将效率最高的Fast JLSampler作为默认采样方式；在需要某种特殊采样方式的场合，直接调用对应的采样模块。

## 实验结果

本节描述在调整算法时观察到的实验结果。这些实验结果未必体现在.mlx文件代码中，也不建议直接作为报告正文的内容；建议以.mlx提供的测试代码为框架，参考本节的内容调整实验参数并得出结论。

- 关于采样：杠杆值采样最慢，性能也与高斯采样类似。在输入矩阵稀疏时，也未见其表现出良好的性能。稀疏符号采样理论上最快，但可能由于matlab对稀疏矩阵的优化不够，导致其稍慢于快速JL采样。采样时应保证规模k>n，否则可能导致杠杆值采样的中间矩阵R奇异。
- 关于矩阵乘法：在稀疏矩阵输入，同样采样规模下，杠杆值采样性能确实优于随机采样，二者的结果也确实随n和k增大收敛至真实值（需要保证k>N/4）；但分析复杂度可知，nk<M时，随机方法才真正降低复杂度，但在这个条件下得到的结果往往完全不可信。若要得到基本准确的结果，需要nk>4M。另外，虽然杠杆值采样可以提升精度，但由于估计杠杆值分布本身十分复杂，在同样的时间复杂度下，其效果反而不如随机采样。
- 关于随机SVD分解：由于IterativeRangeFinder中需要反复计算Y的列与Q列空间正交的部分（类似于直接计算QR分解），导致时间复杂度无法降低。
- 关于LS：由于IterativeLS中使用了二次规划函数quadprog()，而其效率又非常慢，导致IterativeLS效率远远落后于其他方法；另外，建议取k>=2N，否则可能出现1）IterativeLS不收敛；2）k≈N时预处理法使用的预处理矩阵可能奇异。

## 其他

- 测试使用的cpu型号为AMD Ryzen9 7950x3d。
- 在各函数模块内部，已经做了部分（不本质的）优化以尽量节省计算效率。若要对算法进行改进，可以忽略诸如"A*B\*C中是先计算AB还是BC"这样的细节，将精力集中在算法的主要思路上。
- 所有引用[1]的内容，均可在[1]的对应部分中找到文献出处。部分内容存在[1]的表达和原文献不一致的情况，属原文献表述有误。我们已基于理论和仿真分析更正了这些错误，故应以[1]中的内容为准。

## 参考文献

[1] 文献调研（同一仓库中的Review_on_RandNLA.pdf文件）

[2] D. P. Woodruff, “Sketching as a tool for numerical linear algebra,” Foundations and Trends in Theoretical Computer Science, vol. 10, no. 1-2, pp. 1-157, 2014.

[3] P. Drineas, R. Kannanand M. W. Mahoney, “Fast Monte Carlo algorithms for matrices I: Approximating matrix multiplication,” SIAM J.on Computing, vol. 36, no. 1, pp. 132-157, 2006.

[4] P.  G.  Martinsson  and  J. A. Tropp,“Randomized numerical linear algebra: Foundations  \& algorithms,” arXiv:2002.01387v3 [math.NA],15 Mar 20213. https://arxiv.org/pdf/2002.01387.

[5] D. P. Woodruff, “Sketching as a tool for numerical linear algebra,” Foundations and Trends in Theoretical Computer Science, vol. 10, no. 1-2, pp. 1-157, 2014.
