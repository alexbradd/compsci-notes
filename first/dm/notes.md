# Data mining

## Introduction

Data mining emerged in the late 80s due to an explosive growth of data and a
pressing need for the automated analysis of massive data.

Big Data is a term that gets thrown around a lot: it indicates gigantic
quantities of data being collected. The quantity of data is so large that:

1. It facilitates predictions not previously possible
2. It necessitates special processes to deal with

### Machine learning

_"A computer program is said to learn from experience $E$ with respect to some
class of task $T$ and a performance measure $P$, if its performance at tasks in
$T$, as measured by $P$, improves because of experience $E$"_

Suppose we have the experience encoded as a dataset

$$
  D = x_1, x_2, x_3, \ldots, x_N
$$

1. It is called **supervised learning** if, given the desired outputs $t_1,
   \ldots, t_n$, it learns to produce the correct output given a new set of input
2. It is called **unsupervised learning** if it exploits regularities in the
   dataset to build a representation to be used for reasoning or prediction
3. It is called **reinforcement learning** if, producing actions $a_1, \ldots,
   a_N$ which affect the environment and receiving rewards, it learns to act in
   order to maximize rewards in the long term

### Data science

It can be broken into 4 essential parts:

1. Mining data
2. Information analysis
3. Representation or visualization
4. Implication/application of the data, interaction using the data and
   predictions formed from studying it

### Data mining

_"Data mining is the process of identifying valid, novel, potentially useful and
understandable patterns in data"_

The general idea is to build computer programs that navigate through databases
automatically, seeking patterns. Problems:

1. Most patterns will be uninteresting
2. Most patterns will be spurious, inexact or accidental
3. Coincidences
4. Real data is imperfect (garbled data, missing data)

The algorithms we develop will need to be robust enough to cope with imperfect
data and extract regularities that are inexact but useful.

Models can be:

1. _Descriptive_: built for gaining insight?
2. _Predictive_: built for accurate prediction?

The main steps are:

1. Selection
2. Cleaning
3. Transformation
4. Mining
5. Validation
6. Presentation

### Data preparation

Preprocessing and preparation account for 90% of the work (trash-in trash-out
principle). Preprocessing is a necessity since data in the real world is dirty:

1. Incomplete (missing attributes)
2. Contains errors
3. Contains inconsistencies and discrepancies

Sampling is the main technique for selection. It is often used both in a
preliminary "investigation" and the final analysis. We also sample data because
analysing all the set may be too time consuming.

A sample is **representative** if it has the same property (or interest) as the
original set of data. A representative sample works almost as good as the full
set.

We can sample in different ways:

1. Random
2. Sampling without replacing: each selected item is removed from the
   population
3. Sampling with replacement: selected items are not removed from the population
4. Stratified sampling: split the data in partitions and then draw at random
   from each

### Data mining tasks

1. **Regression**: identifies a relation inside a dataset between a target value and
   other values
   - **Linear**: provides a linear relation between input and output
   - **K-Nearest Neighbour**: calculates an average between the neighbours
   - **Tree**: creates various "steps" by dividing the dataset in a tree manner

   Each type of regression fits best a certain type of data.
2. **Classification**: given the input values, we crate a model that tries to
   predict the label of other objects:
   - **Logistic regression**: extension of the linear regression
   - **K-Nearest neighbour**: assigns a label based on the values of the
     neighbouring objects
   - **Decision tree**: extension of the regression decision tree
3. **Clustering**: we have some points and we try to create groups based on the
   data:
   - **K-means**: we look for similarity based on a similarity function. The $k$
     specifies the number of groups the algorithm will create.

     The accuracy of the method depends heavily on the similarity function.
4. **Association**: we try to look create associations between various objects
   (like amazon's "also bought with")
5. Other:
   - Outlier analysis: opposite of clustering
   - Trend and deviation analysis: regression, pattern mining, periodicity
     analysis and similarity-based analysis
   - Text mining, Topic modeling, Graph mining, Data streams
   - Sentiment analysis, Opinion mining...
   - Other pattern or statistical analyses

### Relevant issues

Mining can generate thousands of patterns, but typically not all of them are
interesting. A pattern is **interesting if is easily understood by humans, valid
on new or test data with some degree of certainty, potentially useful, novel or
validates some hypothesis that a user seeks to confirm**. Objective vs
subjective interestingness matters:

1. Objective: based on statistic
2. Subjective: based on the user's beliefs in data

Our methods cannot find all interesting patterns, but most. We will optimize
algorithms by not wasting time on "uninteresting" patterns.

### Pitfalls

**Correlation does not imply causation!**. Just because a trend is similar
between two topics, it does not mean that there is a link between the two.

## Data representation

We will usually see tables:

1. Columns are called **attributes, features, independent variables**
2. The rows are called **instances, observations**
3. **Concepts, target, dependent variables** are still columns, however are
   special because they can be learned

Attributes can be:

1. **Numerical**: numbers, or differences from a reference
2. **Categorical**: values taken from a set:
   - **Nominal**: when only equality make sense. The values serve only as a
     label, they are meaningless.
   - **Ordinal**: when both equality and inequality are meaningful. They are
     categorical values with an imposed order on values.
3. **Binary**: `0` or `1`

Some attributes can have an hierarchical structure (dates, addresses etc.).

### Missing values

Missing values can be present due to various reasons (faulty questionnaires,
censor, anonymous data etc.). **Missing values can have a meaning themselves: if
the absence has a meaning, "missing" is a separate value; if it does not,
"missing" must be handled in a special way.** Missing values are of different
types:

1. **Missing not at random**: the distribution of missing values depends on the
   missing value (e.g. people with high income are less likely to
   report it).

   They are the most difficult to deal with: they can skew the results of the
   analysis. They must be handled on case by case basis.
2. **Missing at random**: distribution of missing values depends on the observed
   attributes, but not the missing value.
3. **Missing completely at random**: Distribution of missing values does not
   depend neither on observed attributes or missing values.

Identifying MNAR and MAR can be difficult and requires domain knowledge.

The best strategy to deal with missing data depends on the application:

1. **Deletion**: we can delete rows with missing data.

   - Pros: simplest method
   - Cons: we can introduce bias or hide relationships
2. **Single imputation** (_imputation = guessing_): we can use other values to
   predict missing ones. Methods: mean/mode, dummy variable, single regression.
3. **Model-based imputation**: we create a model to predict missing values. Methods:
   maximum likelihood, multiple imputation.

We can convert the missing values into a new value and assign meaning to it.
However this increases the difficulty of the mining process. We can use other
data mining methods to imputate missing values. We can also use a "Do Not
Impute" policy: simply use default policy of the mining method for handling the
missing values.

#### List-wise deletion

**We only analyze cases with available data on each variable**. This approach is the
simplest, however we reduce the sample size and we remove information. **Estimates
can be biased if data is not MCAR**.

#### Pair-wise deletion

**We delete cases with missing values that affect only the variable of interest**.
Doing as such means we keep as many cases as possible for each analysis and we
use as much info as possible. **Comparison of results, however, is more difficult
because samples are different each time**.

### Inaccurate values

Data is not collected for the only purpose of mining. Errors and omissions don't
affect the original purpose of data. We need to identify outliers and check for
consistency. Errors in data may be deliberate.

### Geometric view

When data contains only numerical values, every row can be viewed as a point in
$d$-dimensional space. Every column is a point in the space.

Another view is the probabilistic view: every instance is extracted from a
probability distribution.

### From Categorical attributes to numerical

We care about the type of the data because it influences the work we can do on
data. Some algorithms and functions work only on specific data types. We can
also check better for missing/invalid values.

**To transform data from categorical to numerical we use encoders. We can
transform numerical data into ordinal using discretization**.

#### Encoders (Scikit-Learn encoders)

1. **LabelEncoder**: Encodes target labels with values between 0 an $n-1$.

   This replacement can influence the process in unexpected ways: if we map two
   values to 1 and 2 we are implying that the first value is "smaller" than the
   second. We would need to redo the analysis and change the mapping to check
   that our encoding does not influence the analysis.
2. **OneHotEncoder**: Performs a one-hot encoding of features: we map each
   category to one boolean variable.

   The good part is that we use the same values with all the labels. However we
   can generate an enormous amount of variables if we have many categories.
3. **OrdinalEncoder**: Performs an ordinal (integer) encoding of the categorical
   features.

#### Categorical embeddings

A new approach that surfaced recently is applying deep learning to map
categorical variables into Euclidean spaces. Similar values are mapped close to
each other in the embedding space, revealing the intrinsic properties of the
categorical variables.

### Data formats

Most commercial tools have their own proprietary formats. Most tools import
excel an CSV files. There have been attempts to create a common format for data
like ARFF.

DSPL is an open format by Google. It consists in adding XML metadata to a CSV
file.

### Model representation

PMML is an XML markup language to provide  a way for applications to define
models related to predictive analytics and data mining. The goal is to share
models between applications.

## Data exploration

Preliminary exploration of the data is aimed at identifying their most relevant
characteristics. This helps in selecting the right tool for preprocessing and
mining. We also exploit our brain's ability to analyze patterns non captured by
automatic tools.

### Exploration Data Analysis

It is _an approach of analyzing data to summarize their main characteristics
without using a statistical model to having formulated a priori hypothesis_. It
mainly focuses on:

- Visualization
- Clustering and anomaly detection

### Summary statistics

Summary statistics are number that summarize properties of the data. Most
summaries can be calculated in a single pass.

1. **Frequency**: the percentage of time the values occurs in the dataset
2. **Mode**: the most frequent value
3. **Mean**: the most common measure for the location of a set of points. Very
   sensible to outliers.

   $$
    mean(x) = \bar{x} = \frac{1}{m}\sum_{i=1}^m x_i
   $$

4. **Median**:

   $$
   median(x) = \begin{cases}
     x_{(r+1)} &\quad \text{if m is odd} \\
     0.5(x_r + x_{r+1}) &\quad \text{if m is even}
   \end{cases}
   $$

5. **Percentile**: the p-th percentile is a value $x_p$ such that $p\%$ of the
   observed values of $x$ are less  than $x_p$
6. **Trimean**: weighted mean of the first, second and third quartile

   $$
     TM = \frac{x_{25} + 2x_{50} + x_{75}}{4}
   $$

7. **Truncated mean**: A mean that discards data above and below certain percentiles (e.g.
   5th and 95th)
8. **Interquantile mean**: A mean that truncates the data at the 25th and 75th percentiles.
   If the data is sorted, we have:

   $$
   X_{IQM} = \frac{2}{n}\sum_{i=0.25n+1}^{0.75n} x_i
   $$

9. **Range**: the differences between max and min
10. **Variance**: the most common measure for spread. Very sensitive to
    outliers.

    $$
    variance(x) = s^2_x = \frac{1}{m - 1}\sum_{i=1}^m (x_i - \bar{x})^2
    $$

    Alternatives to variance that are more resilient to outliers:

    $$
    \begin{gathered}
      AAD(x) = \frac{1}{m}\sum_{i=1}^m |x_i - \bar{x}| \\
      MAD(x) = median(\{|x_1 - \bar{x}|, \ldots, |x_m - \bar{x}|\}) \\
      \text{interquantile range}(x) = x_{75\%} - x_{25\%}
    \end{gathered}
    $$

### Correlation analysis

Given two attributes, we measure how strongly one attribute implies the other.
We mainly look for linear relationships between variables. They can be positive
or negative. Linear correlation is symmetric.

Given two attributes we need to measure how strongly one attribute implies the
other, based on the available data.

- Numerical variables: Pearson's product moment coefficient
- Ordinal variables: Spearman's rank correlation coefficient
- Categorical variables: $\chi^2$ statistic test
- Binary variables: Point-biserial correlation

**Correlation does not mean causation**:

1. Correlation does not imply causation
2. Causality has direction, correlation typically doesn't
3. Confounding variables can cause attributes to be correlated

### Outliers

Outliers are data objects that do not comply with the general behaviours or model
of the data. Most analysis methods consider outliers as noise/exceptions.
Outliers may be selected using:

- **Manual inspection** and domain knowledge
- **Statistical tests** that assume a distribution or probability model for the data
- **Distance measures** where objects that are a substantial distance from any other
  cluster
- **Deviation based methods** identify outliers by examining differences in the main
  characteristics of objects in a group

Outliers are frequently filtered out, but **can be the focus of the analysis**.

### Normalization

We might need to normalize attributes that have a very different scales.

Range normalization converts all values to the range $[0;1]$:

$$
x'_i = \frac{x_i-min_i x_i}{max_i x_i - min_i x_i}
$$

Standard score normalization forces variables to have mean of 0 and standard
deviation of 1

$$
x'_i = \frac{x_i - \mu}{\sigma}
$$

### Visualization

Visualization is the conversion of data into a visual or tabular format so that
characteristics of the data and the relationships among data items or attributes
can be analyzed or reported.

It is one of the most powerful and appealing techniques for data exploration:

1. Pattern-matching and visual brain
2. Can detect general patterns and trends
3. Can detect outliers and unusual patterns

### Projecting data into a lower dimensional space

When we use high-dimensional data, if we do not want to use multi-dimensional
representations like spider plots, we need to reduce the dimensionality of the
data.

1. We can find a linear relation between variables and project them (PCA)
2. Otherwise we need to find non-linear projections (t-SNE)

#### Principal Component Analysis (PCA)

Typically applied to reduce the number of dimensions of data. The goal is to
find a projection that captures the largest amount of variation in data.

Given $N$ data vectors from n-dimensions, we find $k<n$ orthogonal vectors (the
principal components) that can be used to represent data.

Steps:

1. Normalize
2. Compute $k$ orthonormal vectors
3. Each input data point ca be written as a linear combination of the $k$
   component principal vectors.

The principal components are sorted in order of decreasing "significance", or
strength. Data size can be reduced by eliminating the weak components, i.e those
with low variance. Using the strongest principal vectors it is possible to
reconstruct a good approximation of the original data.

#### t Distributed Stochastic Neighbour Embedding

Data in high dimensions never fills the enter space and always lives within som
lower dimensional manifold. t-SNE is used to map highdimensional data ino 2 or 3
dimensions.

Points from the original space are mapped onto "map points" in 2D/3D. Unlike
PCA, the mapped points are not a linear combination of original attribute
values, and the axes of mapped space are not linear combination of original
axes. t-SNE tries to preserve local distanecs to nearby points, unlike PCA with
tries to preserve global distances between points.

Steps:

1. Define a probability distribution over pairs of high-dimensional data points
   so that:
   - Similar data points have a high probability of being picked.
   - Dissimilar points have an extremely small probability of being picked.
2. Define a similar distribution over the points in the map space:
   - Minimize Kullback-Leibler divergence between the two distributions with
     respect to the location of the map points.
   - To minimize the score, it applies gradient descent

Different initializations will lead to different results. Should be applied with
a reasonable number of dimensions.

#### Force-directed layout

The idea is to map complicated into 2D is not limited to high dimensional data.
We can map any graph of data points into 2D provided we have some dissimilarity
value between pairs of nodes. It works by moving points around in the mapped 2D
space until convergence.

## Association rules

Association rule mining is finding frequent patterns and associations among sets
of items in transaction databases, relational databases or their information
repositories. **Given a set of transactions, we find rules that will predict the
occurrence of an item based on the occurrences of other items in a
transaction**.

**Itemsets are the fundamental pattern in association rule mining**. Rules are
represented as $X \implies Y$ where $X,Y$ are itemsets. We have two evaluation
metrics: **support and confidence**

1. **Support**: fraction of transactions that contain both $X$ and $Y$
2. **Confidence**: Measures how often items in $Y$ appear in transactions that
   contain $X$

For $\{Bread\} \implies\{Milk\}$ we have:

$$
\begin{gathered}
  s = \frac{\sigma(\{Bread,Milk\})}{\text{\# of transactions}} \\
  c = \frac{\sigma(\{Bread,Milk\})}{\sigma(\{Bread\})}
\end{gathered}
$$

Our goal is finding all rules in a set $T$ having:

1. **Support greater or equal than minsup threshold**
2. **Confidence greater or equal than minconf threshold**

**One of the biggest problems is defining these thresholds**. One way to find our
rules is brute-forcing the problem: enumerating all possible rules; computing
the support and confidence of each and pruning every one that fails the
criteria. This approach is computationally prohibitive.

We can decouple the support and confidence requirements. First we find the itemsets
with the adeguate support and then do the same with confidence.

### Frequent itemset

Our main focus will be **frequent itemsets: a set whose support is grater or
equal than the minsup threshold**. We define $s$ the support and $\sigma$ the
support count of an itemset.

We use a **two step approach to mining rules**: first we **generate the frequent
itemset generation** and then we **generate rules with high confidence**. However
frequent itemset generation is computationally expensive: $2^d$ with for $d$
items.

#### Brute-force generation

Each itemset in the lattice generated by brute-forcing combinations is a
candidate frequent itemset. We then need to count the support of each candidate
by scanning the database. We need to match each transaction against every
candidate, giving us $\mathcal{O}(NMw)$ with $N$ transactions, $M$ candidates
for transaction and $w$ the length of itemsets.

We have three paths:

1. **Reducing** the number of **candidates** $M$
2. **Reducing** the number of **transactions** $N$
3. **Reducing** the number of **comparisons** $NM$

#### Reducing candidates

**Apriori principle**: if an itemset is frequent, then all of its subsets must
also be frequent.

The apriori principle hold due to the following property of the support
(anti-monotone property):

$$
  \forall X,Y: \quad (X \subseteq Y) \implies s(X) \geq s(Y)
$$

Using this principle we can prune superset of sets found to be infrequent.

Pruning using the apriori principle is not very efficient due to frequent
database calls. An optimization it the **eclat algorithm** and consists in using
a **vertical database** instead of a binary one: each column contains the T-ids of
the transactions in which an element appears. This means that for $X$ and $Y$,
computing the T-ids of $XY$ means doing a simple set  intersection of the two
initial sets.

The performance optimization **doesn't address the huge candidate sets that need
to be created**, it simply makes counting items more efficient. We need a way of
eliminating candidate generation.

##### FP-growth

We introduce a new data structure (FP-tree) that is **highly condensed structure
for pattern mining**. We then use divide and conquer for computation. Candidate
generation is avoided by using a sub-database test only.

**Steps**:

1. Construct the frequent pattern tree
2. For each frequent item $i$ compute the projected FP-tree
3. Recursively mine conditional FP-trees and grow frequent patterns obtained for
   far
4. If the conditional FP-tree contains a singe path, simply enumerate all the
   patterns.

Infrequent patterns would be already removed before starting this algorithm.

(For constructing the FP-tree, see slides _Association Rules_ from _35..37_).

The FP-tree structure preserves all the relevant information and is very compact.

### Rule generation

Given a frequent itemset $L$, we need to **find all non-empty subsets $f$ such that
$f \implies L - f$ satisfies the minimum confidence requirement. If $|L| = k$,
then there are $2^k - 2$ candidate association rules**.

Confidence does not have an anti-monotone property. However **confidence of rules
generated from the same itemset has an anti-monotone property**:

$$
L = \{A,B,C,D\}: \quad c(ABC \implies D) \geq c(AB \implies CD) \geq c(A \implies BCD)
$$

Confidence is anti-monotone in the number of items on the rhs of the rule. This
means we can adapt the apriori logic to confidence pruning.

### Rule assessment measures

If minsup is set **too high**, we could **miss itemsets containing rare items**. If it
set **too low**, it is **computationally expensive** and the number of sets is very
large. **A single minsup may not be effective**.

**Lift is the ratio of the observed joint probability of $X$ and $Y$ to the
expected joint probability if they were statistically independent**:

$$
lift(X \implies Y) = \frac{sup(X\cup Y)}{sup(X)sup(Y)} =
  \frac{conf(X\implies Y)}{sup(Y)}
$$

Lift is a **measure of the deviation from stochastic independence**; it measures
the surprise of the rule: a lift close to 1 means that the support of a rule is
expected considering the supports of its components.

### Summarizing itemsets

**An itemset is called maximal if it has no frequent supersets**. The set of all
maximal frequent itemsets is given as
$M = \{X|X\in F \land \not\exists X\subseteq Y: Y \in F\}$. $M$ is a **condensed
representation** of the set of all frequent itemsets, because **we can determine
whether any itemset is frequent or not by using $M$**. However, we cannot use $M$
to determine $sup(X)$, **we can only use it to have a lower-bound**.

An **itemset is closed if all supersets of $X$ have strictly less support**. The set
of all closed frequent itemsets $C$ is a **condensed representation, as we can
determine whether an itemset $X$ is frequent, as well as the exact support of
$X$**.

A frequent itemset $X$ is a **minimal generator if it has no subsets with the same
support**. Thus, all subsets of $X$ have strictly higher support.

### Searching for small communities

Communities involve many people talking about the same things. We can use this
to define "topics". More formally: **we enumerate the complete bipartite subgraphs
$K_{s,t}$, which have $s$ nodes on the left and $t$ nodes on the right**. The left
nodes link to the same node on the right, forming a fully connected bipartite
graph. **Searching for such graph can be viewed as a frequent itemset mining
problem**.

We can view **each node $i$** as a **set $S_i$ of nodes it points to**. $K_{s,t}$ would
be a **set $Y$ of size $t$ that occurs in $s$ sets $S_i$**. Looking for $K_{s,t}$ is
equivalent to settings the frequency threshold to $s$ and look at layer $t$

### Mining sequences

Given a database $D$ containing $N$ sequences, **the support of a sequence $r$ in
$D$ is defined as the total number of sequences in $D$ that contains $r$**:

$$
sup(r) = |\{s_i \in D | r \subseteq s_i \}|
$$

The **relative support of $r$ is the percentage of sequences that contain $r$**:
$rsup(r) = sup(r) / N$.

Given a minsup threshold, we say that **$r$ is frequent i $sup(r) \geq
minsup$**.

In sequence mining **we need to consider all possible permutations**, non just
the combinations.

We can **search the sequence prefix tree using a level-wise (breadth-first)
search**. Given the set of frequent sequences at level $k$, **the algorithm
generates the candidate for level $k+1$ and compute the support of each
candidate** and prune the not frequent ones. **For each sequence $s_i$ in D, we
check if a candidate $r$ is a subsequence of $s$, if it is the support of $r$ is
incremented**. Once the frequent sequences at level $k$ are computed the $k+1$
candidates are generated. **For each leaf $r_a$, the sequence is extended with the
last symbol of any other leaf $r_b$ that shares the same prefix**:
$r_{ab} = r_a + r_b[k]$. If $r_{ab}$ is infrequent, we prune it.

### Sequential pattern mining

**Association rules do not consider the order of transactions, however, in many
applications the ordering is significant**.

A sequence is a ordered list of itemsets. We denote a sequence by $\langle a_1,
\ldots a_n \rangle$. An element of a sequence is denoted by $\{x_1, \ldots,
x_n\}$. We assume without loss of generality that items in an element of a
sequence are in lexicographic order.

**We need to find all the sequences that have a user-specified minimum support**.
Each such sequence is called a frequent sequences, or sequential pattern. **The
support for a sequences is the fraction of total data sequences in the input
that contains this sequence**.

Given a database $D$ of $N$ sequences and a sequence $r$, we define the **support
count $r$** as:

$$
sup(r) = |\{s_i | r \text{ is a subsequence of } s_i\}|
$$

And the support (or relative support) $rsup(r) = sup(r) / N$

The **apriori principle still applies**: if sequence is not frequent, then every
supersequence is not frequent.

### Association rules for classification

Association rule mining assumes that the data consists of a set of transaction.
Thus the typical tabular representation of data used in classification must be
mapped into such a format. **Association rule mining is then applied to the new
dataset and the search is focused on association rules in which the tail
identifies a class label**. The rules are pruned using the pessimistic
error-based methods and finally sorted to build the final classifier.

## Clustering

Clustering algorithms **group a collection of data points according to some
distance measure**. Data points in the same cluster should have small distance
from one another, while points in different clusters should be at a large
distance from each other. The quality of clustering depends on both the
similarity measure, its implementation and its ability to discover some or all
the hidden patterns.

The data structure we will work with is the usual. We will be also working with
a distance/similarity matrix.

### Introduction

#### Distance measures

Given a space and a set of points on a space, a distance $d(x,y)$ maps two
points to a real number and satisfies three axioms:

1. $d(x,y)\geq 0$
2. $d(x,y) = 0 \iff x = y$
3. Is symmetric
4. $d(x,y) \leq d(x,z) + d(z,y)$

**Jaccard distance**: measures how dissimilar two sets are. Variables need to be
binary variables.

$$
d(x,y) = 1 - J(x,y) = 1 - \frac{|x\cap y|}{|x\cup y|}
$$

It can also be interpreted as the percentage of identical attributes.

**Hamming distance** between two vectors is the number of components in which
they differ. Given $p$ variables and $m$ matching components

$$
d(x,y) = \frac{p-m}{p}
$$

**Cosine similarity** is computed as:

$$
s(x,y) = \frac{\sum_1^n x_i y_i}{\sqrt{\sum_i^n x_i^2}\sqrt{\sum_i^n y_i^2}}
$$

The **cosine distance** is defined as $d(x,y) = 1- s(x,y)$ while the angular
cosine distance is computed as $d(x,y) = c\times \frac{arccos(s(x,y))}{\pi}$
with $c=1$  if the vectors may contain positive and negative values and $c=2$ if
the vectors contain only positive values.

The **edit distance** between two strings is the smallest number of insertions
and deletions of single characters that will transform the first into the
second. The edit distance can be computed as the LCS of the two strings as such

$$
d(x,y) = |x| + |y| - 2|LCS|
$$

#### Normalization

To measure similarity between points, we need to use **compatible scales**. This
means that normalization is a must. We have have different normalizers at our
disposal.

#### The curse of dimensionality

In **high dimensions, almost all pairs of points are equally far away from one
another**. This means that any two vectors are almost orthogonal.

### Hierarchical clustering

Hierarchical clustering is, by far, one of the most common clustering
techniques. It **produces a dendrogram** (hierarchy) of **nested clusters** that can be
analyzed and visualized.

#### Agglomerative (bottom-up)

First we consider **one cluster for each item**. At **each step we merge the most
similar clusters until we generate one cluster**.

This approach is the most popular technique because it is **unbiased** (does not
favour any shape). It is, however, the **most expensive**:

- Space is $\mathcal{O}(n^2)$ since it uses a proximity matrix
- Time is $\mathcal{O}(n^3)$ since we need to update $n$ times the $n^2$
  proximity matrix

The complexity can be reduced to $\mathcal{O}(n^2\log(n)$ for clever
implementations.

#### Distance between clusters

Previously we defined a distance between two points. However, how can we measure
the distance between two clusters? We have **different standard methods**:

1. **Single linkage**: we can take the minimum distance of the points between the two
   clusters
2. **Complete linkage**: like single, however we take the max
3. **Mean or centroid distance**: we calculate the centroid for each cluster and
   measure the distance between centroids
4. **Group average**: we use the average between an element in one cluster and an
   element in the other.

#### Determining the number of clusters

Hierarchical clustering generates $n$ partition of the data. We need some
quality measures to determine the actual number of clusters.

**Cohesion** measures how closely related are objects in a cluster:

$$
WSS(C) = \sum_{i=1}^k \sum_{x_j \in C_i} d(x_j, \mu_i)^2
$$

**Separation** measures how well separated a cluster is from other cluster.

$$
BSS(C) = \sum_{i=1}^k |C_i|d(\mu, \mu_i)^2
$$

Where $\mu$ is the centroid of the whole dataset while $\mu_i$ is the centroid
of cluster $C_i$.

We can then **plot the WSS and BSS for every clustering and look for knee/elbow in
the plot** that shows a significant variation of the evaluation metric.
Knees/elbows do not tell the whole story, **sometimes evaluating the plot of the
data points can be more effective**.

If a cluster is in an euclidean space, we can identify it using its centroid or
its convex hull. In case of non-euclidean spaces we can define a distance an use
a medoid (an existing point data we take as representative that minimizes the
sum of distances to all other points in the cluster).

### Representative based clustering

The hypothesis is that **there exists a point that summarizes the cluster**. A
common choice for such a point is the one that is the mean of the points in the
cluster.

#### K-Means

It is a **greedy, iterative** and stochastic approach to find a clustering that
**minimizes the SSE objective**:

$$
SSE(C) = \sum_{i=1}^k \sum_{x_j \in C_i} ||x_j - \mu_i||^2
$$

For each iteration:

1. We **calculate the centroid of the previous iteration's cluster**. If we are at
   the **first iteration**, we **pick two random points**.
2. If the **previous centroid is not the calculated one**, we **reassign** the centroid.
   **If it is, we stop iterating**.
3. We **assign the points to the clusters**.

It is a greedy algorithm, this means that **it can converge to a local optimal
instead of a globally optimal solution**.

Cluster assignment takes $\mathcal{O}(nkd)$ time since for $n$ points, it
computes its distance to each of the $k$ clusters, which takes $d$ operations
in $d$ dimensions. The centroid re-computation step takes $\mathcal{O}(nd)$ time.
Assuming $t$ iterations, **the total time is $\mathcal{O}(tnkd)$**.

In terms of **IO**, it requires **$\mathcal{O}(t)$ full database scans**.

**Centroid initialization** is the **most crucial steps** of the algorithm since it can
wildly affect the final result. We usually have 3 approaches:

1. **Pick points as far away from one other**
2. **Pick the first points at random**. While there are fewer than $k$ points add
   the point whose minimum distance from the selected points is as large as
   possible.
3. **Cluster a sample of the data using an optimal approach, e.g. hierarchical
   clustering, into $k$ cluster**. Then **pick the point closer to the centroid** of
   the cluster, for each cluster.

If there are $k$ "real" clusters, then the chance of selecting one centroid from
each cluster is small. This means that selecting an optimal initial centroid is
very difficult.

Some **preprocessing we can do to improve data quality is normalizing data and
removing outliers**. While **after** clustering we can:

1. **Eliminate small clusters** (outliers)
2. **Split loose clusters** (clusters with high SSE)
3. **Merge clusters that are close and have low SSE**

This post-processing **can also be done during the clustering process**.

K-Means can have some **problems** when:

1. Clusters **differ in size and density**.
2. Clusters **have non-globular shapes**.
3. Data contains **outliers**.

K-Means requires that we specify the number of cluster beforehand. One way to
find is to do a knee/elbow analysis.

#### Mean-shift

It is an iterative, non-parametric and versatile algorithm. It **searches for the
mode (point of highest density) of a data distribution**.

It is not really a clustering algorithm. **It is an algorithm to estimate the
distribution of a set of points**. We start from a certain point and **define a
region of interest**. We **compute the mean of the points in the region and we move
the center of the region in the new region**. We **repeat** this process **until center
of the region and center of mass of the points coincide**. The found point can be
used as a representative.

To define a **cluster**, we **execute the algorithm from different points in space**.
The **points touched by trajectories that lead to the same mode** (attraction basin)
should be in the **same cluster**.

The algorithm **doesn't need the number of clusters** and **doesn't assume anything
about the shape of the clusters**. Mean-shift is also **robust w.r.t
initializations**, while K-Means is not. Classical mean-shift, however, is **more
computationally expensive** ($\mathcal{O}(Tn^2)$ with $T$ iterations).

#### Expectation maximization

K-Means assigns each point to only one cluster. The approach can be **extended by
considering soft-assignment of points to cluster, so that each point has a
probability of belonging to each cluster**. We assume that **each cluster $C_i$ is
characterized by a multivariate gaussian distribution** and thus defined by a mean
vector $\mu_i$ and covariance matrix $\Sigma_i$. A **clustering is then defined by
a vector of parameters $\theta$** defined as $\theta = \{\mu_i, \Sigma_i, P(C_i)\}$
Where $P(C_i)$ are the priori probabilities of all the clusters $C_i$. The **goal
is to choose $\theta$ that maximizes likelihood**, that is

$$
\theta^\star = arg max_\theta P(D|\theta)
$$

The **general idea** of the algorithm is this:

1. Start with an **initial estimate** of $\theta$
2. **Iteratively re-score patterns against the mixture density** produced by $\theta$
3. The **re-scored patterns** are used to **update $\theta$**
4. **Patterns** are belonging to the **same cluster if they are placed by their
   scores in a particular component**.

### Density based clustering

Representative clustering methods are suitable for finding ellipsoid-shaped
clusters, or at best convex shapes. For **non convex clusters**, these methods have
**trouble**. Density-based clustering methods can mine such non-convex clusters.

#### DBSCAN

Let us introduce some definitions:

1. The **neighbourhood within a radius $\epsilon$** of a given object is called the
   **$\epsilon$-neighbourhood** of the object.
2. A **core point** contains at **least `minpts` objects in its $\epsilon$-neighbourhood**.
3. A **border point** is **not a core point**, but **inside the neighborhood of a core point**.
4. A **noise point** is **neither** a **core** nor **border point**.

**Density** corresponds to **having at least `minpts` points within a radius $\epsilon$**.
A **border point has fewer than `minpts` within $\epsilon$, but is in the
neighborhood of a core point**.

1. **Directly density reachable:** an object $x$ is directly density reachable from
   object $y$ **if $x$ is within the $\epsilon$-neighbourhood of $y$ and $y$ is a
   core object**
2. **Density reachable:** an object is density-reachable from object $y$ **if there is
   a chain of objects $x_1, \ldots, x_n$ where $x_1 = x$ and $x_n = y$ such that
   $x_i$ is directly density reachable from $x_{i-1}$**
3. **Density connected:** An object $p$ is density connected to $q$ w.r.t
   $\epsilon$ and `minpts` **if there is an object $o$ such that both $p$ and $q$
   are density reachable from $o$**
4. **Density based cluster:** a density based cluster is defined as a maximal set of
   density connected points.

DBSCAN needs to compute the $\epsilon$-neighborhood for each point. If the
**dimensionality is not too high** this can be done efficiently using a spatial
index structure in **$\mathcal{O}(n\log(n))$**. If the **dimensionality is high**, we
need **$\mathcal{O}(n^2)$**. Once the $\epsilon$ neighborhood has been computed, the
algorithm **needs only a single pass over all the points to find the density
connected clusters**. Overall, the **average complexity is $\mathcal{O}(n\log(n))$**
and the **worst is $\mathcal{O}(n^2)$**.

#### HDBSCAN

**Extends DBSCAN by converting it into a hierarchical clustering algorithm and then
using a technique to extract a flat clustering based in the stability of
clusters**.

It defines the **core distance** of a point as **the maximum distance of a point to
its k-th nearest neighbour ($core_k(x)$)**. Thus, **points in high density areas
will have low core distance**, while **points in low density areas will have a high
core distance**. This provides a local inexpensive estimate of density.

The **new distance metric** is defined as such:

$$
d_{mreach-k}(a,b) = max \{core_k(a), core_k(b), d(a,b)\}
$$

Using the core distance and the original distance metrics $d$, **this distance
keeps dense areas with lower core distance at the same distance while pushing
away sparser points**. Using the distances, we **compute the minimal weight
spanning tree.** This spanning tree is like a **dendrogram**.

We now need to **condense** the tree into clusters. We **navigate the hierarchy from
the top to bottom and at each split we check the size of the merged clusters**. If
a cluster has **fewer points than the threshold**, then **the smaller clusters are
eliminated, otherwise both clusters are maintained**. At which point a point $p$
"fell out of the cluster" and **at what point that happened is stored in
$\lambda_p$**.

Once the condensed dendrogram has been calculated, we **want to select what
persists and have a longer lifetime since short lived clusters probably
represent artifacts**.

In the end, we can **assign to each point a probability of belonging to a cluster
based on its $\lambda_p$**.

### Silhouette Analysis

See python notebook `SilhouetteAnalysis`.

## Linear regression

Regression tries to **compute a function that predicts the value of some variables
based on the others**.

When we work with regression, we need to **think also about model usage**, and not
only about model building. How do we **evaluate a model**? Given $N$ examples,
**linear regression computes a model $y = w_0 + w_1 x$ so that for each point
$y_i = w_0 + w_1 x_i + \epsilon_i$ we evaluate the model by computing the
residual sum of squares:**

$$
RSS(w_0, w_1) = \sum_{i=1}^N \epsilon^2_i
$$

The goal of linear regression is thus to **find the weights that minimizes said
$RSS$**.

The best way to compute the minimal values of $RSS$ is to use the **gradient of
$RSS$. To get some values we use gradient descent**:

$$
\begin{aligned}
  & \text{while not converged} \\
  & \quad \vec{w^{(t+1)}} = \vec{w^{(t)}} - \eta \nabla RSS(\vec{w^{(t)}})
\end{aligned}
$$

Usually **$\eta$ changes over iterations**.

### Multiple linear regression

Given $D$ input variables, we assume that the **output $y$ can be computed as**:

$$
y = w_0 + \sum_{j=1}^D w_j x_j + \epsilon
$$

The model cost is computed using the **residual sum of squares $RSS$ as**:

$$
RSS(w) = \sum_{i=1}^N (y_1 - w_0 - \sum_{j=1}^D w_j x_{i,j})^2
$$

Some other measures are:

1. **Total sum of squares**: $TSS= \sum_{i=1}^N (y_i - \bar{y})^2$
2. **Coefficient of determination**: measures **how well the regression line
   approximates the real data points**. When it is **1, the regression line
   perfectly fits the data**.

   $$
   R^2 = 1- \frac{RSS}{TSS}
   $$

In general, given a set of input variables $x$, a set of $N$ examples $x_i, y_j$
and a set of $D$ features $h_j$ computed from the input variables $x_i$,
**multiple linear regression assumes a model**:

$$
y_i = \sum_{j=0}^D w_j h_j(\vec{x_i}) + \epsilon_i
$$

Where $h_j(\cdot)$ identifies variables derived from the original inputs.

**MLR aims at minimizing $RSS(\vec{w})$**:

$$
RSS(\vec{w}) = \sum_{I=0}^N (y_i - \sum_{j=0}^D w_j h_j (\vec{x_i}))^2
$$

For this purpose we can apply **gradient descent**:

$$
\begin{aligned}
  & t = 0 \\
  & \text{init } w^{(0)} \\
  & \text{while not converged} \\
  & \quad \text{for }(j = 0; \, j \leq D; \, j = j + 1) \\
  & \quad \quad \Delta w_j = -2 {\textstyle\sum_{i=1}^N} h_j(\vec{x_i})(y_i - \hat{y_i}(\vec{w^{(t)}})) \\
  & \quad \quad w_j^{(t+1)} = w_j^{(t)} - \eta \Delta w_j \\
  & \quad t = t + 1 \\
\end{aligned}
$$

### Model evaluation

**Models should be evaluated using data that have not been used to build the model
itself**. The available data should be split between training and test. **Generally
we reserve**:

- **$1/2$ for each**
- **$2/3$ for training and $1/3$ for testing**

For small or unbalanced datasets, samples might not be representative.

#### Cross validation

The **most robust way to evaluate your model**. Two steps:

1. **Data is split into $k$ subsets of equal size**
2. **Each subset** in turn is **used for testing and the remainder for training**.

This is called **$k$-fold cross-validation** and **avoids overlapping test sets**.
Often the subsets are **stratified** before cross validation is performed.

The **standard is stratified ten-fold cross-validation** (ten has been observed
empirically to be the best value). Stratification reduces the estimate's
variance. To reduce even more the variance we can repeat cross validation
multiple times (e.g 5x2 or 10x10).

### Overfitting

Overfitting is defined as a very good performance on the training set but
terrible performance on the test set. The opposite of overfitting is
underfitting.

In linear regression, usually **having too small degree leads to underfitting,
while too high degree to overfitting**. Overfitting is **also associated to large
weights estimates**. To prevent it we can add to $RSS$ a **term to penalize large
weights** to avoid overfitting. We call this procedure **regularization** and we have
two ways of regularizing:

1. **Ridge regression** ($L_2$):

   $$ RSS(\vec{w}) + \alpha \|\vec{w}\|_2^2 $$

2. **Lasso regression** ($L_1$): usually the preferred method.

   $$ RSS(\vec{w}) + \alpha \|\vec{w}\|_1 $$

**Lasso tends to zero out less important features and produces sparser solutions**.

#### Choosing $\alpha$

To select the best value of $\alpha$ we **cannot use the test set since it is
going to be used for evaluating the final model**. We need to **reserve part of the
training data to evaluate possible candidate values of $\alpha$ and to select
the best one**.

If we have **enough data, we can extract a validation set from the training data
which will be used to select $\alpha$**. **If we don't** have enough data, we should
select $\alpha$ by **applying k-fold cross-validation over the training data
choosing the $\alpha$ corresponding to the lowest average cost over the k-folds**.

## Classification

Given an unlabeled dataset, we need a way to decide the class of an element.

### Logistic regression

**Similar to linear regression, however we use the line not to predict the value,
but to draw a divider between two classes**.

We define a **score function** similar to the one used in linear regression. Then
the **label is determined by the sign of the score value**.

$$
\begin{gathered}
  Score(\vec{x_i}) = \sum_{j=0}^D w_j h_j (\vec{x_i}) \\
  \hat{y_i} = sign(Score(\vec{x_i}))
\end{gathered}
$$

Logistical regression **computes the probability of assigning a class to an
example**: $P(y_i|\vec{x_i})$. For this reason, logistic regression **assumes that**:

$$
\begin{gathered}
  P(\hat{y_i} = 1|\vec{x_i}) = \frac{1}{1+e^{Score(\vec{x_i})}} \\
  P(\hat{y_i} = 1|\vec{x_i}, \vec{w}) = \frac{1}{1+e^{\vec{w}h(\vec{x_i})}}
\end{gathered}
$$

In the second one we use $h$ for all the feature transformation.

It then **searches for the weight vector that corresponds to the highest
likelihood** $l(\vec{w}) = \prod_{i=0}^N P(y_i|\vec{x_i}, \vec{w})$. For this
purpose, **it performs a gradient ascent on the log likelihood function**
$ll(\vec{w}) = \ln l(\vec{w})$.

To classify an example $x$:

1. We **select the class with the highest probability** $P(Y=y|x)$;
2. **Or we check if the ratio of probabilities is greater than one**:

   $$
   \frac{P(y=1|\vec{x})}{P(y=-1|\vec{x})} = e^{\vec{w}h(\vec{x})} > 1
   $$

   Choosing the positive class if it is, otherwise, the negative class.

**Equivalently** we can check if the **natural log** is greater than 0. This means **we
can obtain a classification that assigns $Y=-1$ by checking that
$\sum_{i=0}^D w_i h_i(x) < 0$ and $Y=1$ otherwise**.

The **logistic curve fits better 0/1 data than linear** and results in a better
decision boundary. **Error is monotonic in distance** from boundary. Moreover, the
boundary in the linear case is more sensitive to outliers, while logistic is
not.

#### Overfitting and regularization

Like in the linear case, **$L_1$ and $L_2$ can reduce overfitting and produce
sparse solution**. Overfitting is associated with large weights to limit
overfitting.

- **$L_1$ uses the sum of absolute values**, which penalizes large weights and at
  the same time promotes sparse solutions

  $$ l(\vec{w}) - \alpha \|\vec{w}\|_1 $$

- **$L_2$ uses the sum of squares**, which penalizes large weights

  $$ l(\vec{w}) - \alpha \|\vec{w}\|_2^2 $$

We of course need to choose a suitable $\alpha$.

#### Cross-validation

We can use **cross-validation on classification like we did previously**. We
**calculate predictions on data points in each fold**. The **final performance** is
**computed using the predictions computed on all the folds**.

#### Multiclass classification

Logistic regression assumes that there are only two classes of values. What if
we have more? We use **one-versus-the-rest evaluation**: for each class, we create
one classifiers that predicts the target class against all the others.

One alternative approach is to **change the model itself to be multiclass**. The
optimisation routine **minimizes loss or maximizes likelihood over the multiple
classes at once**.

Multinomial logistic regression uses the following function

$$
P(Y_i = j) = \frac{e^{\vec{w_j}h(\vec{x_i})}}{\sum_j e^{\vec{w_j}h(\vec{x_i})}}
$$

### Classification metrics

#### Confusion matrix

Focuses on the predictive capability of a model:

| Actual class | Predicted class | -     |
|:------------:|:---------------:|:-----:|
| -            | Yes             | No    |
| Yes          | `#TP`           | `#FN` |
| No           | `#FP`           | `#TN` |

$$ Accuracy = \frac{TP+TN}{TP+TN+FP+FN} $$

Note that **often accuracy can be misleading**. **We can also use the cost of
misclassification in place of the cardinalities**.

#### Precision and recall

- **Precision**: percentage of **items classified as positive that are actually
  positive**

  $$ p = \frac{TP}{TP+FP} $$

- **Recall**: percentage of **positive examples tat are classified as positive**

  $$ r = \frac{TP}{TP+FN} $$

The **higher the precision, the lower the FPs**, the **higher the recall, the lower
the FNs**.

We define the **F1-measure** as:

$$ F1-measure = \frac{2rp}{r+p} $$

The **higher the F1, the lower both the FPs and FNs**.

#### Sensitivity and specificity

- Sensitivity **evaluates the ability to correctly identify the elements of the
  positive class** and it is computed as the true positive rate (TPR)

  $$ TPR = \frac{TP}{TP + FN} $$

- Specificity **estimates the probability to correctly identify the elements of the
  negative class** and it is computed as the true negative rate (TNR)

  $$ TNR = \frac{TN}{TN + FP} $$

### Comparing two models

How can we evaluate the performance of two models and say whether the difference
between the two was (or not) due to random fluctuations?

**We apply the t-test, compute the p-value and compare it to a threshold**.

We call the test **paired if we compute the mean/variance of the models on the
same dataset**, while **unpaired if we use different datasets**.

#### Multiple observations

Say we perform a statistical test and we **repeat the test on twenty different
observations**. What is **the chance that at least on of the observations will
receive a p-value less than our threshold**?

The **Bonferroni correction** is a correction that calculates the **probability of
making one mistake** as $p-value / \#tests$

### Probabilistic classifiers

In logistic regression, we set the threshold for classification to 0.5. However
**we can move the threshold a higher/lower**. By modifying the threshold,
**we are modifying the precision and recall of the model**:

- If we **increase** the threshold we are **increasing precision, but reducing recall**
  (more false negatives)
- If we **decrease** the threshold we are **decreasing precision, but increasing recall**
  (more false positives)

#### Precision-recall curve

The **relation** between precision-recall is **a curve**. Different classifiers have
different curves. The **ideal classifier is the one that has always precision to
one**.

To choose between classifiers, we choose the that has a better F1 measure or
that has the curve nearer to one.

#### ROC curves

Another tool is the analysis of the ROC curve of the classifier. The **ROC plot is
the plot of the true positive rate against the false positive rate**.

$$
\begin{gathered}
  TPR = \frac{TP}{TP+FN} \\
  FPR = \frac{FP}{TN+FP}
\end{gathered}
$$

The **performance** of a single classifier is represented as **a point on the curve**.
To **compute the curve**, we **simply change the threshold by some quantum and
calculate the point**.

Together with the curve a **diagonal line** is plotted. It **represents the
performance of a random guess**. **Below this line, prediction is opposite of the
true class**. The **better** the classifier performs, **the closer the curve is to the
$(0;1)$ point**; the **worse** it performs the **closer to the polar opposite** it goes.

We can **evaluate two models by comparing the area under the ROC curve**. The one
**closer to 1 is the better**.

### Naive Bayes

It starts from **Bayes's theorem**:

$$
P(C|A) = \frac{P(A|C)P(C)}{P(A)}
$$

Our **class will be $C$**, while the **attributes will be $A$**.

An **example** is usually represented as a **tuple of attributes**. Given the target $y$
(identifying the class values for the instance) we are **looking for the class
with the highest probability for $x$**.

$$
\begin{aligned}
  class & = \mathrm{arg max}_y P(y|\vec{x}) \\
  P(y|\vec{x}) & = \frac{P(\vec{x}|y)P(y)}{P(\vec{x}) \\
    & = \frac{P(x_1|y)\cdot P(x_n|y)P(y)}{P(\vec{x}) \\
\end{aligned}
$$

Naive Bayes classifiers **assume that attributes are statistically independent**.
Thus the evidence splits into independent parts.

Since this is a **probabilistic classifier**, all our **discourse about threshold
still holds**.

1. **Training**:
   - Count the **frequency of tuples** $(x_i, y)$ for **each attribute and class**
   - Use the counts to **compute estimates of the class probability** $P(y)$ and the
     **conditional probability** $P(x_i | y)$
2. **Testing**:
   - Given an example $x$, we **compute the most likely class**.

We are assuming **that attributes are equally important** and that they are
**statistically independent**. The **independence assumption is almost never correct**.

If an **attribute value does not occur** with every class value, the **corresponding
probability will be zero and posteriori-probability will also be zero**. A typical
remedy to this problem is to **add $1$ for every $(x_i, y)$ attribute value-class
pair**. This process is called **smoothing** and the **$1$ is the Laplace estimator**. We
are **not obligated to use 1**. If prior knowledge is available, we can add weights
to the various estimators (all weights must sum to 1).

If we have a **missing value**:

- During **training**, the **instance is not included in the frequency count** for
  attribute value-class combinations
- During **testing**, the **attribute will be omitted from calculation**

#### Numeric attributes in naive Bayes

What if some (or all) the attributes are numeric? We have two options: **we
discretive the data to make it either binary or discrete**. To compute the
probability density for each class **we assume that the attributes have a gaussian
probability distribution**. We then we use the **mean and standard deviation to compute
the probabilities**.

### Bayesian belief networks

Naive Bayes works surprisingly well, even if the independence assumption is
violated. This happens because classification doesn't require accurate estimates
as long as maximum probability is assigned to the correct class.

Bayesian belief networks **provides a way to represent relationships among a set
of random variables**. Relations are represented as **graphs**: **attributes** are **nodes**
and **relations** are **edges**. The graph must be **acyclic**.

**Each node is associated with a probability table**. If a **node $X$ does not have
any parents, then the tables contains only prior probabilities**. If a **node
has parents, the table contains the conditional probability
$P(X|Y_1, \ldots, Y_k)$**.

Values of variables can be known or unknown. We can **estimate probabilities over
unknown variables given known values**. In general the **inference is NP-complete**,
but we can approximate with methods like Monte Carlo.

### K-nearest neighbour

To classify an example $x$, **we select the $k$ data points of the training set
that are "most similar" to $x$**. Then we **assign the most frequent class among the
$k$ selected**.

This is an example of **instance-based learning**: it stores the training records
only, **no model is computed**. It **uses the training records to predict an unknown
class label**. It is the simplest form of learning.

The only thing we need to choose is the $k$: **if $k$ is too small**, classification
might be **sensitive to noise points**; **if $k$ is too large**, neighbourhood may
**include quite dissimilar examples**.

The **similarity measure** used are **the same ones we used for clustering**. Like
clustering, we also need to apply normalization when needed.

To make k-nearest neighbour efficient, we **need to use some intelligent data
structures**:

1. **KD-trees**: We **split the space hierarchy** using a **tree generated from the
   data**. To **find the neighbour** of a specific example we can **navigate the tree**
   using the example.

   We **add the points iteratively to the tree**. **Each new point falls in a leaf and
   splits** the region around it based on one of its attributes.

   To **search** for the nearest neighbour, we **navigate the tree to reach the leaf
   and check**. Then we **backtrack up the tree** to check **nearby regions until all
   k-nearest neighbours are found**, i.e when the closest region is further than
   the k-th closest point so far.

   **Search complexity** depends on the **depth of the tree** ($\mathcal{O}(\log n)$).
   **Occasional rebalancing** of the tree may be needed.
2. **Ball-trees**: **same principle as KD-trees**, but it uses **hypershperes**. **Balls
   may allow for a better fit to the data** and thus more efficient search.

### Decision trees

A decision tree is a **tree** where each **internal node is a test on an attribute**. A
**branch represents an outcome** of the test. A **leaf** node represents a **class label**
or class label distribution. At each node, **one attribute is chosen to separate
training examples of different classes**. A **new case is classified by following a
matching path to a leaf node**.

We construct trees in **two steps**:

1. **Top-down tree construction**: initially all the **training examples are at the
   root**. The examples are **recursively partitioned by choosing one attribute
   at a time**.
2. **Bottom-up tree pruning**: we **remove subtrees or branches**, in a bottom-up
   manner, to improve the estimated accuracy on new cases.

#### Choosing a splitting attribute

In what way can we split examples into areas that contain mainly examples of one
class? At **each node**, **available attributes are evaluated** based on separating the
classes of the training examples using either a **purity or impurity measure**.
**Typical measures** used are the **information gain, information gain ration and the
gini index**.

##### Information gain

Information is **measured in bits**:

1. Given a **probability distribution**, the **info required to predict an event** is
   the distribution's **entropy**
2. **Entropy** gives us the information required in bits

$$ \mathit{entropy}(p_1, \ldots, p_n) = -p_1\log_2 p_1 - \ldots - p_n\log_2 p_n $$

The **information gain** is the **difference between the information before the split
and the information after the split**. The **information after the split** on
attribute $A$ is computed as the **weighted sum** of the entropies on each split.

Since we are trying to bring order into the caos, **a good split is one that
reduces entropy, therefore has the biggest gain**.

##### Information gain ratio

If we have **highly branching attributes** (e.g. ids, primary keys etc) we can break
the simple information gain method. As a matter of fact, if we split by ID, we
have maximal gain since we reduce the entropy to 0.

Since basic **information gain favors attributes with many values**, we need to
**correct the bias** towards said attributes. Information gain ratio does
exactly that: it is large when data is evenly spread and small otherwise. It
does this by **correcting the information gain by taking the intrinsic
information of a split into account**. **Intrinsic information** computes the
**entropy of a distribution of instances into branches**:

$$ \mathit{IntrinsicInfo}(S,A)= -\sum\frac{|S_i|}{S}\log\frac{|S_i|}{S} $$

We can say that the intrinsic information is the entropy of $A$, independent of
the class.

**Information gain ratio** normalizes information gain by:

$$ \mathit{GainRation}(S,A) = \frac{Gain(S,A)}{IntrinsicInfo(S,A)} $$

##### The Gini index

The **Gini index** for a dataset $T$ contains examples that from $n$ classes is
defined as:

$$ \mathit{gini}(T) = 1-\sum_{j=1}^n p^2_j $$

With $p_j$ the relative frequency of class $j$ in $T$.

If a **dataset $D$ is split on $A$**, the gini index of said split is the **weighted
sum of the singular gini indexes**. The **reduction of impourity** is defined as the
**difference between the initial gini index and the gini index after the split**.

The Gini coefficient **measures the inequality among values of a frequency
distribution**.

The attribute that provides the **largest reduction (or the smallest Gini of the
split) is chosen to split the node**.

Usually the gini index is used to generate **binary splits**.

#### When do we stop?

There are several possible stopping criteria, some are:

1. All **samples for a given node belong to the same class**
2. There are **no remaining attributes** for further partitioning
3. There are **no samples left**
4. There is **nothing to gain in splitting**

#### Numerical attributes

First we **sort all the numerical values, including the class labels**. Then, we
**check all the feasible cut points and choose the one with the best information
gain**.

We **do not need to sort all values for each node we traverse**. The **sort order of
the children of a node can be derived from that of the parent**. Thus we **reduce
the complexity** of the derivation to **$\mathcal{O}(n)$**.

#### Binary vs multiway splits

Splitting on a nominal attribute exhausts all information in that attribute. **A
nominal attribute is tested at most once** on any path in the tree. **Numerical
attributes may be tested several times**, thus the **tree** can become **hard to read
and interpret**. Two possible solutions:

1. **Pre-discretize**
2. Use **multi-way splits** instead of binary ones

#### Generalization and overfitting in trees

**Too many branches may indicate overfitting** and reflect anomalies due to noise or
outliers. This results in poor accuracy for unseen samples. Two approaches to
**avoid overfitting** are:

1. **Prepruning**: **We halt the construction early**. We **do not split** a node if this
   would result in the **goodness measure falling below a threshold**. It is
   difficult to choose an appropriate threshold.
2. **Postpruning**: We **remove branches from a fully-grown tree**. We have two pruning
   operations:
    - **Subtree raising**
    - **Subtree replacement**: considers **replacing a subtree only after considering
      all its subtrees**

   Some **possible strategies** for choosing when to act are:
   - **Error rate estimation**: we prune **only if it reduces the estimated error**.
     Since error on the training data is not a useful estimator, a **holdout set
     must be kept for pruning**.
   - Significance testing
   - MDL principle

#### Model trees and regression

Decision trees can also **be used to predict the value of a numerical target
variable**. **Regression and model trees** work similarly to decision trees: **they
search for the best split that minimizes an impurity measure**.

1. **Regression trees**: prediction is computed as the **average of numerical target
   variable in the subspace**
2. **Model trees**: leaves use a **linear model to predict the target value in the
   subspace**.

As **impurity** measure, we are going to use the **standard deviation reduction**.

$$ SDR = \sigma(D) - \sum_i \frac{D_i|}{|D|}\sigma(D_i) $$

Where $D$ is the original data, $D_I$ are the partitions and $\sigma$ is the
standard deviation of the target.

#### Decision stumps

The **simplest decision trees** possible and also the main building blocks for
boosting methods. They are **a root and leaves**.

1. For categorical attributes:
   - We use one branch for each attribute value
   - We use one branch for one value and one branch for all the others
   - Missing values sometimes are treated as a special value
2. For numerical attributes: two leaves defined by a threshold value selected
   based on some criterion

## Ensemble methods

We **generate a set of classifiers** from the training data. We can then **predict
class labels of previously unseen cases by aggregating predictions made by
multiple classifiers**. We use **majority vote** for classification and average for
regression.

Mathematically, having multiple independent classifiers is advantageous since
**the probability that the majority of the classifiers is wrong is lower than that
of one wrong prediction by one of the single classifiers**.

But how do we create multiple independent classifiers for the same dataset?

### Bagging (Bootstrap aggregation)

Given a dataset $D$, we are going to **generate $k$ training datasets $D_i$ using
bootstrap** (random sampling with replacement). We then **compute $k$ models $M_i$
using each of the $D_i$**.

For **prediction**, each classifier **$M_i$ computes its prediction for $x$**. The
__bagged classifier $M^*$__ returns the class predicted by the **majority of the
models**. When class values are -1 and 1, the output of the ensemble can be
computed as

$$ M^* = sign(\sum_{t=1}^k M_i(x)) $$

**Models may be weighted** differently based on their estimated performance.

Bagging can **also be applied to regression** by simply **averaging** the output of the
models.

Bagging works because **it reduces variance by voting/averaging**. In some
pathological situations the overall error might increase.

We say that a **classifier is unstable when small changes to the datasets lead to
great changes to the model**. If the algorithm is **unstable**, **bagging almost always
improves performance**. Bagging stable classifiers is unproductive.

> Example of unstable classifiers: decision/regression trees, linear regression,
> neural networks.
>
> KNN is an example of stable classifier.

#### Random forests

To **improve performance** of decision tree, we can use a **forest of uncorrelated
trees** to have a greater variance reduction. Random forests are **ensembles of
unpruned decision tree learners with randomized selection of features at each
split**. Each tree depends on the values of a random vector sampled independently
and with the same distribution for all trees in the forest. **Using a random
selection of features to split each node yields error rates that are more
robust with respect to noise**.

Since we are using **bootstrapping** to train our model, we **use only a subset
of the complete data** to train each classifier. This means that **we can reuse
the data points** that haven't been used in training this model **as testing**.

Random forests are **easy to use** (they require only two parameters, the number of
trees and the %variables for split) and they have **high accuracy**. We can also
**avoid overfitting if we use a large number of trees**.

#### Boosting

The idea is to **create a model and check where we made some mistakes, we then
create a new model focused on correcting the mistakes of other models**.

**AdaBoost** computes a **strong classifier as a combination of weak classifiers**:

$$ H(x) = sign(\sum_{t=1}^T \alpha_t h_t(x)) $$

Where $h_t$ is the output of the $t^\text{th}$ weak classifier. $\alpha_t$ is a
weight assigned based on its estimated error.

$$ \alpha_t = \frac{1}{2}\ln (\frac{1-\epsilon_t}{\epsilon_t}) $$

Boosting works like this:

1. **Weights are assigned** to each training example
2. A series of **$k$ classifiers is iteratively learned**
3. **After** a classifier $M_i$ is learned, the **weights are updated**
4. The **next classifier** $M_{i+1}$ will **focus on the training tuples that were
   misclassified** by $M_i$
5. The __final $M^*$ is a weighted sum__ of all the outputs

The **starting base classifier should not be too complex** and their **error should
not become too large too quickly**. **Boosting tends to overfit the data**.

#### Gradient tree boosting

We build a **sequence of tree predictors** by repeating three simple steps:

1. Learn a **basic** predictor
2. Compute the **gradient of a loss function** with respect to the predictor
3. Compute a **model to predict the residual**
4. **Update the predictor** with the new model
5. Goto **2**

The **depth of the trees control the maximum allowed level of interaction between
variables**, e.g with decision stumps we allow no interaction. Empirically we saw
that **trees should have between 4 and 8 leaves**. Using **small learning rates
results in drastic improvements in the generalization, at the cost of more
computational power**.

##### eXtreme Gradient Boosting

Efficient and scalable implementation of gradient boosting for classification
and regression trees. Deals only with numerical values.

##### LightGBM

It employs a different notion of complexity: we specify the number of leaves of a
tree.

#### Stacking generalization

Suppose we have **several models that all solve the same problem**. **Stacking enables
us to combine them**. **Stacking generalization puts another model on top of the
other models that learns when to use which classifier**.

## Text representation

### Natural language processing

**Natural text processing is hard** since natural languages are ambiguous, dependant
on context and can depend on concepts not easily comprehensible for machines.

The **previous method** for analyzing text was to **understand everything, from syntax
to the meaning of each word**. This method is **nearly impossible** due to the nature
of human languages. The **main problems** are:

1. **Word-level ambiguity**: some words are both nouns and verbs
2. **Syntactic ambiguity**
3. **Presupposition**: relying on common knowledge and reasoning of a human
   interlocutor

### Information retrieval

Since NLP is too difficult, it has never broken through until very lately.
**Information retrieval is a much simpler task**: we need to **identify a document
relevant to some query**.

There **two modes of access**:

1. **Pull mode**: typical of **search engines**, the uses takes initiative and needs ad
   hoc information
2. **Push mode**: typical of **recommender systems**, needs stable information about
   what a client needs

There are also **two possible modes of document selection**:

1. **Document selection**: each **document is either relevant or not**
2. **Document ranking**: documents are **ranked on the basis of their relevance with
   respect to the user query**

The **quality** of text retrieval systems is done through **3 metrics**:

1. **Precision**: $\frac{Relevant\cap Retrieved}{Retrieved}$
2. **Recall**: $\frac{Relevant\cap Retrieved}{Relevant}$
3. **F-score**: $\frac{2precision * recall}{precision + recall}$

#### Document similarity

To compute document similarity we need to **model** a document: we see a document as
**a set of words**. We can then **create a table matching the presence (or frequency)
of words to various documents**. It is a **very sparse** representation since
documents often contain far fewer words than all the known vocabulary.

Using **this representation our document can become a vector in feature space**.
This space is very high dimensional and corresponds to all keywords. **Relevance
is measured with an appropriate similarity measure defined over the vector
space**.

Let us start with a **simple similarity function**: $f(q, d) = \sum q_i d_i$ where
$q_i$ and $d_i$ are the presence or absence of a keyword $i$. Of course it is
**too simple since it doesn't consider how many times we match a word**.

Let us **now consider the frequency of each word** (normalized by document length to
avoid bias). Now, however, **we rank higher more frequent, and often less
informative, words**.

Let us introduce **inverse document frequency**: it **measures how much information
the word provides**. This metric **penalizes words that occur frequently in many
documents**:

$$ IDF(w) = \log \frac{M}{k} $$

Where $k$ is the number of documents in which $w$ appears and $M$ is the number
of documents. **When a word is not in the set of documents, the formula leads to a
division by zero, so usually we find $k + 1$ at the denominator**.

We can combine **term frequency with inverse document frequency to build a
representation of documents that we can use to compute document similarity or
distance**. Given a document $d$ from a corpus containing $M$ documents, the
**vector elements $d_i$ are computed as**:

$$ d_i = f(w_i, d)\log\frac{M}{k_i} $$

#### Preprocessing text data

The preliminary step is **removing non-content related information** (e.g HTML),
**lowercasing** everything and **remove punctuation**. Then we **remove stop-words**, i.e
words that are too common and do not add nothing (e.g 'a', 'the'). Another thing
we can do is **word stemming**: words with a common prefix get reduced to said
prefix.

### Word embedding

The point of word embeddings is to improve the bag of words model by improving
on the biggest weakness of the model: the lack of **usage of context information**.

Embeddings are **dense representations of words** rather than documents. **We store
each word as a point in continuous space**: a word will be represented by a **vector
of fixed number of dimensions**. Embeddings are **generated from a huge corpus using
supervised methods**.

Embeddings can be viewed as a **multi-class classification problem with a massive
parameter space**. One of the first ones was word2Vec, developed by google.

Embeddings has some **useful properties**:

1. Translation in the vector space is meaningful
2. Semantics are additive
3. Neighbours in space are semantically related
4. Induces relationships between words such as part-of-speech, type-of and
   geographic relationships
5. Embeddings also place similar concepts close together. This is useful for
   discovering implied (but unknown) properties.

Embeddings work **very good if the vocabulary is fixed**. If we need to add a new
word, we do not have an embedding for it. **Another approach, fasttext, splits
words into character sequences and learning from the character n-grams. Then it
combines the embeddings to form words**.

The concept of embedding **can be extended to other data types**. The principle is
the same, the model to create them are different.

### Entity embeddings for categorical variables

**One-hot encoding** is used to **preprocess categorical data** for algorithms that work
on numerical values only. **It can generate a massive amount of variables**.
Embeddings **can translate large sparse vectors into a lower dimensional space
that preserves semantic relationship**: they map categorical variables into
euclidean spaces. The **mapping is learned by a neural network using a supervised
training process**.

This approach **reduces memory usage** and speeds up the process. Since it maps
similar values close to each other, it **can also reveal some intrinsic property
about the data**.

## Optimization

Given a certain domain and a target function, we need to **find the
maximum/minimum**. If we **know the analytical form**, we can use **gradient
ascent/descent**. If using gradient method, we need to be aware of the **possibility
of finding a local optimum**. In that case we use a variant with "restarts".

### Black box optimization

If we **do not know the analytical form**, what can we do?

#### Random search and hill climbing

We **randomly generate values for the parameters and we keep comparing the results
we get until we find the best solution**. We run until we found the best solution
or we ran out of time. Random search **fails miserably if the search space is big**,
however it is **independent of the difficulty of the optimization problem**.

**Hill climbing** assumes that **small changes in the solution do not translate in big
changes in the parameters**. We find a **solution by generating random values and
then tweaking the parameters**, if this solution is better we move to these new
parameters. We do this until we found the ideal solution or we run out of time.
The algorithm is **greedy**, so it may converge to a local optimum.

**Steepest ascent hill climbing** is a **variation** that **makes the algorithm more
greedy**. Instead of just tweaking one time, we **build multiple variations and we
choose the best one among all variations**. Like its simpler form, it is greedy.

**Tabu search** is similar to steepest ascend hill climbing, however the algorithm
is **able to exit out of local optima by allowing a worsening move if no
improvement can be done**. In addition, a **list of prohibited location is
maintained** to avoid going back to previously seen points.

#### Population based methods

The basic idea is to **evolve a population of candidate solutions using the
concepts of survival of the fittest, variation and inheritance**. Such an
algorithm follows the **following steps**:

1. **Initialization**: randomly generates the initial population
2. **Evaluation**: evaluates the population of candidate solutions using the given
   fitness function
3. **Selection**: selects promising solutions from the current population by making
   more copies of better solutions at the expense of the worse ones.
4. **Variation**: Processes selected solutions to generate new candidate solutions
   that share similarities with selected solutions but are novel in some way
5. **Replacement**: incorporates new candidate solutions into the original
   population

The **terminology** used is similar to **genetics**.

##### Selection

The selection step is usually done with a **tournament of size $k$**: we first
randomly **pick $k$ solutions from the original population and then select the best
solution** out of this subset. **Binary tournaments** ($k=2$) are the **most popular**.

##### Variation

While selection and generation weren't problem dependent, **variation is
typically grounded in the underlying representation**.

Variation operators **process selected promising solutions to generate new
candidate solutions** that share features with selected solutions. We follow two
principles: **variation** (introducing novelty) and **inheritance** (reusing the old).

**Variation** is done by two operators:

1. **Crossover**: combines bits and pieces of two operators
   - The basic idea is to **randomly select one string position (crossing point)
     and exchange all bits after this position**. We can also have multiple point
     crossover.
2. **Mutation**: makes small perturbations to promising solutions
   - The simplest way to do mutation is **bit-flip mutation: flip every bit with a
     specified probability. Usually one or few bits should be mutated**.

##### Replacement

The basic idea is that once we have a new population of **offspring of the same
size** we **simply replace the old with the new**.

Another method, called **elitism**, assumes that the **offspring is smaller than the
original population**. In this case we **replace the worst performing strings of the
original population**.

### Real-coded genetic algorithms

The idea is to **extend the principles seen before to another coding (real
values)**. To do this we need to implement **new variation operators**.

With this coding, **candidate solutions are vectors of real values and random
initialization generates a random number from an interval for each variable**.

1. **Arithmetic crossover**: given two parents $x=(x_1, \ldots, x_n)$ and
$y=(y_1,\ldots,y_n)$ we **choose a random variable $i$ and a random $\alpha \in
[0,1]$ and obtain two children by linearly combining the $i$s**:

   $$
   \begin{gathered}
    o_1 = (x_1, \ldots, \alpha y_i+(1-\alpha)x_i, \ldots, x_n) \\
    o_2 = (y_1, \ldots, \alpha x_i+(1-\alpha)y_i, \ldots, y_n)
   \end{gathered}
   $$
2. **Simple mutation**: we **change each variable with a fixed probability**. To change
   a variable, we generate a small random number in $[-\delta,\delta], \delta>0$
   vary small and add this number to the variable.
   3. **Gaussian mutation**: The **change is generated according to the Gaussian
   distribution** $\mathcal{N}(0,\sigma^2)$ where $\sigma^2$ is the variance of
   the mutation steps, which is a small number.

### Permutations

**Ordering and sequencing problems form a special class**. The task is solved by
arranging some object in a certain order. We will **represent the problem with a
list of $n$ integers, each of which appears exactly once**.

Can we apply a genetic algorithm to this class of problems?

Of our previous steps, **evaluation and selection do not require any modification**.
**Recombination and mutation need to be adapted**.

**Normal single-point crossover will often lead to inadmissible solutions**. We need
to define a **more specialized operator** that focuses on **combining order or
adjacency information from the two parents**. The same reasoning goes is
applicable to mutation operators.

#### Mutation

The **mutation parameter** will reflect the **probability that some operator is
applied once to the whole string**, rather than individually in each position.

1. **Insert mutation**: Pick **two variables at random and move the second to follow
   the first**. Preserves most adjacency and order information.
2. **Swap mutation**: Pick **two variables at random and swap their position**.
   Preserves most adjacency information but disrupts order more.
3. **Inversion mutation**: Pick **two variables at random and invert the substring
   between them**. Preserves most adjacency information but disrupts order.
4. **Scramble mutation**: Pick a **subset of variables at random and randomly
   rearrange them**.

#### Crossover

1. Choose an **arbitrary part from the first parent**
2. **Copy** this part **to the first child**
3. **Copy the numbers that are not in the first part to the first child**: starting
   from the cut point of the copied part, using the order of the second parent
   and wrapping around at the end.
4. We do **the same for the second child**.

## Feature selection

See **notebooks**.
