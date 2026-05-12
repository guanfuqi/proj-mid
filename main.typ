#import "@preview/touying:0.7.3": *
#import themes.university: *

#import "@preview/numbly:0.1.0": numbly

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [低空无人机视觉感知任务的特征压缩编码研究],
    subtitle: [基础项目实践中期答辩],
    author: [吴钦鸿 王渝凯],
    date: datetime.today(),
    logo: box(image("assets/HIT-logo.png", height:1em)),
  ),
  // config-common(show-bibliography-as-footnote: bibliography("基础项目.bib",style:"gb-7714-2015-numeric")),
  // config-common(show-bibliography-as-footnote: bibliography("基础项目.bib",style:"gb-7714-2015-numeric")),
)
#set heading(numbering: numbly("{1}.", default: "1.1"))
#set text(lang:"zh", size: 22pt)
#show bibliography: set heading(outlined: false)
#set text(font: "Microsoft YaHei")
#title-slide()

#outline(depth:2)

= 研究内容简介

== 编码

学习型图片压缩（LIC）的经典结构，是在自编码器中加入熵模型。它提供了降低码长的能力，首次为学习型压缩给出优化思路。

// $
//   EE_(x ~ p_x) D_("KL")[q || p_(tilde(y)|x)]
//   = EE_(x ~ p_x) EE_(tilde(y) ~ q) [
//     log q(tilde(y) | x) - log p_(tilde(x)|tilde(y))(x | tilde(y)) - log p_(tilde(y))(tilde(y))
//   ] + "const."
// $

// 在学习型熵模型的$EE_(x ~ p_x) D_("KL")[q || p_(tilde(y)|x)]$中，$q_(tilde(y)|x)$ 表示实际潜在的分布，$p_(tilde(y)|x)$表示熵模型预测的潜在的分布。
学习型熵模型，用神经网络拟合真实隐变量的分布。到cheng2020@chengLearnedImageCompression2020 为止，学习型熵模型的优化经历了超先验、空间上下文、混合高斯模型等历程，LIC在编码方面的研究已经趋于完善。
#utils.fit-to-height[
#image("assets/image-6.png")
]

== 压缩 <压缩>
压缩的优化主要在于*如何分配量化间隔*。

*掩码注意力*对特定区域增幅，相当于对其更细地量化。针对视觉任务优化时，常使用*掩码注意力*作为适配器插入压缩模型层间，在空间/频域调整幅值分配。

*交叉注意力*通过引导不变内容的复用，将更细致的量化分配到没有重复的区域中。针对多图压缩优化时，常使用*交叉注意力*参考另一图的信息。
#columns(3,)[
      #image("assets/image-7.png", height: 160pt)
      #text(size: 20pt)[频域掩码注意力]
      #image("assets/image-8.png", height: 160pt)
      #text(size: 20pt)[空间域掩码注意力]
      #image("assets/image-10.png", height: 70pt)
      #image("assets/image-11.png", height: 70pt)
      #text(size: 20pt)[图间参考]
]

== 对齐
在低空图像领域，学习型图片压缩已经能很好地应用到单视角的图片压缩和视频压缩任务中。

我们以多视角低空图像压缩作为具体改进方向。

现有的多视角图像压缩，从立体视图压缩发展而来。正如@压缩 提到的，常用交叉注意力参考另一图的信息。典型结构如LDMIC@zhangLDMICLearningbasedDistributed2022：
#columns(2)[
  #image("assets/image-4.png", height: 120pt)
  #colbreak()
  将其他视图的特征$accent(f, -)'_k $作为值和键，将当前视图的特征作为查询，执行交叉注意力操作，混合出新特征图，这种混合，常被成为“*对齐*”。
]

*研究内容：对低空多视角图像，通过两种注意力机制，保持压缩图片的质量和任务精度。*

= 已完成的任务

== 数据集调研
无人机的数据集，以城市交通为主要场景。我们调研了一些红外、多视角的数据集。
#utils.fit-to-height()[
#image("assets/image.png")
]

== 基线压缩方法测试

#slide(composer: (3fr, 2fr))[
#utils.fit-to-height()[
#figure(
  image("assets/image-1.png", height: 300pt),
  caption: "压缩方法在MODT数据集上的表现"
)
]
][
  #alternatives[
    对LDMIC, Cheng2020, 以及传统图像压缩方法在双视角数据集MDOT做了基线测试。

    JPEG, HEVC, VVC都是传统的图像压缩方法。
    其中VVC-intra对两个视角独立压缩。所以联合压缩的方法有VVC和LDMIC。

    *观察到，VVC相对VVC-intra，LDMIC相对Cheng2020，都没有优势。*
  ][
  这引导我们去分析MDOT的数据特性。
  #image("assets/image-2.png")
  #image("assets/image-3.png")
  #utils.fit-to-height()[从以上两个例子可见，不同视角的图片虽然处于同一场景，但视角间*形变*剧烈，*亮度*差距也大。]
  ][
    #image("assets/image-2.png")
    *跨视图对齐的基础，是跨视图的不变性。*

    数据集的视图间虽然存在不变性，但不是像双目视图那样的像素级对应，受到亮度和角度的制约，不变性上升到更高的层次。
  ][
    对此，提出两个假设：
    #block(
      fill: rgb("#e3f2fd"),
      radius: 6pt,
    )[
      - 视图间不变性层次较高，需要针对性设计对齐模块。
    ]

    #block(
      fill: rgb("#fff3e0"),
      radius: 6pt,
    )[
      - 视图间不变性层次较高，在高级指标中更能体现。
    ]
  ]
]

== 假设一：需要针对性设计

#slide(composer: (3fr, 2fr))[
#utils.fit-to-height()[
#figure(
  image("assets/6339714313e6cc3f3381031850c70506.png"),
  caption: "LDMIC在InStereo2K和MDOT两个数据集上的表现"
)
]
][
      在此基础上，对比LDMIC在MDOT和双目视图数据集InStereo2K上的表现。

      可以认为数据集MDOT相比普通双目视图更复杂。
      
      印证了“数据集的视图间虽然存在不变性，但不是像双目视图那样的像素级对应”的观点。
      
      *需要针对这种带角度和了亮度差距的情况做出针对性的设计。*
]
// #slide(composer: (3fr, 2fr))[
//   #alternatives[
//   === 对于假设1
//   - 考虑更针对多视图这一场景，将注意力块的应用范围，从整个特征图缩小到视图之间的匹配区域，或者感兴趣区域。
//   - 为应对亮度差异，在上述区域应用其他域的对齐，比如在频域做交叉注意力。

//   ][
//   === 对于假设2
//     #utils.fit-to-height[
//     机器视觉相比人类视觉，关注高频信息和边缘区域更多，关注的区域也有所不同。不同的视觉任务的关注点也不同。@liImageCompressionMachine2024
//     #image("assets/image-5.png")
//     将压缩模型针对下游任务插入掩码注意力适配器，对特征图的频域和空间域重新分配幅度。
//     ]
//   ]
// ][
//     对此，提出两个假设：
//     + 视图间不变性层次较高，需要针对性设计对齐模块。
//     + 视图间不变性层次较高，在高级指标中更能体现。
// ]


== 假设二：探索在高级指标上的表现

#figure(
image("assets/a6fac88296e4fcbfe28944564d9041bd.png",width: 70%),
caption: "LDMIC在MDOT目标检测任务的性能",
)
普遍而言，随质量指数降低，任务精度下降。但在某些场景下，压缩过程可以去除语义无关特征，一定程度上改善任务精度。\
假设“*视图间不变性层次较高，在高级指标中更能体现*”具备可行性。

= 后续任务

== 后续任务

#slide(composer: (3fr, 2fr))[
  #alternatives[
  === 对于假设1
  - 考虑更针对多视图这一场景，将注意力块的应用范围，从整个特征图缩小到视图之间的*匹配区域*，或者*感兴趣区域*。
  - 为应对亮度差异，在上述区域应用其他域的对齐，比如在*频域做交叉注意力*。

  ][
  === 对于假设2
    #utils.fit-to-height[
    机器视觉相比人类视觉，关注高频信息和边缘区域更多，关注的区域也有所不同。不同的视觉任务的关注点也不同。@liImageCompressionMachine2024
    #image("assets/image-5.png")
    将压缩模型针对下游任务插入*掩码注意力适配器*，对特征图的频域和空间域重新分配幅度。
    ]
  ]
][
    #block(
      fill: rgb("#e3f2fd"),
      radius: 6pt,
    )[
      - 视图间不变性层次较高，需要针对性设计对齐模块。
    ]

    #block(
      fill: rgb("#fff3e0"),
      radius: 6pt,
    )[
      - 视图间不变性层次较高，在高级指标中更能体现。
    ]
]


// #magic.bibliography()
= 参考文献
#text(lang:"en")[
#bibliography("基础项目.bib", style: "gb-7714-2015-numeric", title: none)
]