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
equivalent to settings the frequency threshold to $s4 and look at layer $t$

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
distance from each other.
