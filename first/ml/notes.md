# Machine Learning

## Introduction

_A computer program is said to learn from experience E with respect to some
class of tasks T and performance metric P, if it improves with experience E._

Machine learning is the sub-field of AI where knowledge comes from experience
and induction.

In traditional programming, we give data and a program to the machine and it
produces an output. With machine learning we flip the paradigm: we give data and
a desired output and the machine writes an algorithm.

Machine learning can be categorized in three categories:

1. **Supervised learning**: we learn the model
   - Goal: **estimating the unknown model that maps known inputs to known
     outputs**
   - Possible problems: classification, regression, probability estimation
2. **Unsupervised learning**: we learn the representation
   - Goal: **learning a more efficient representation of a set of unknown
     outputs**
   - Possible problems: compression, clustering
3. **Reinforcement learning**: we learn to take decision
   - Goal: **learning the optimal policy**
   - Possible problems: Markov decision problem (MDP), partially decidable MDP,
     stochastic games

Some dichotomies:

1. Parametric vs Nonparametric
   - Parametric: fixed and finite number of parameters
   - Nonparametric: the number of parameters depends on the training set
2. Frequentist vs Bayesian
   - Frequentist: use probabilities to model the sampling process
   - Bayesian: use probability to model uncertainty about the estimate
3. Generative vs Discriminative
   - Generative: Learns the joint probability distribution $p(x, t)$
   - Discriminative: Learns the conditional probability distribution $p(t|x)$
4. Empirical Risk Minimization vs Structural Risk Minimization
   - Empirical Risk: Error over the training set
   - Structural Risk: Balance training error with model complexity

## Supervised learning

The oldest, most mature and widely used sub-field of machine learning. **Given a
training data set including desired outputs**
$\mathcal{D} \{\langle x,t
\rangle\}$ from some unknown function $f$. We need to
**find a good approximation of $f$ that generalizes well on the test data**.

The **input variables** $x$ are called **features**/predictors/attributes. The
**output variables** $t$ are called **targets**/responses/labels. If $t$ is:

- **Discrete**: we have a **classification** problem
- **Continuous**: we have a **regression** problem
- The **probability** of $x$: we have a **probability estimation** problem

We can use this type of learning when:

1. There is no human expert
2. Humans can perform the task, but cannot explain how
3. The desired function changes frequently
4. Each user needs a customized function

### Overview

We want to approximate $f \in \mathcal{F}$ given $\mathcal{D}$. The **steps** in
doing so are:

1. **Define a loss function** $L$ that for any possible function, specifies how
   bad is the candidate compared to the target $f$;
2. Choose some **hypothesis space** $\mathcal{H}$, a subset of all the possible
   candidates (note: the hypothesis space may not contain our target);
3. **Optimize** to find an approximate model $h$ with the **minimum loss**.

With these steps we are doing functional approximation. With these steps, **we
are assuming that we can compute the ideal loss function**, thus that we know
our original target $f$. The difference with supervised learning is that
**supervised learning is the same minimization problem but with an unknown
target**.

Since we can only compute the loss function based on the dataset, **we can see
the problem as an optimization against a noisy version of the target**. The
**more noise**, the **worse** our approximation will be. **Larger hypothesis
spaces are more susceptible to noise in the data**.

There is no perfect solution, the best approach depends on the task at hand.

## Linear models for regression

The goal of regression is to **learn a mapping from input $x$ to continuous
output $t$**.

Linear models are **linear w.r.t the input features**. Linear models are useful
because they can be solved analytically. Augmented with kernels, it can model
non-linear relationships.

A linear model in the parameters $\mathbf{w}$ is **defined as follows**:

$$
y(x,w) = w_0 + \sum_{j=1}^{D-1} w_jx_j = \mathbf{w}^T \mathbf{x}
$$

### Loss functions

Given a loss function, we can define the **average loss**:

$$
E[L] = \iint L(t, y(\mathbf{x}))p(\mathbf{x}, t)d\mathbf{x} dt
$$

We now need now to **define a loss** $L(t, y(\mathbf{x}))$. A **common choice**
for the loss function is the **squared loss** function:

$$
E[L] = \iint (t - y(\mathbf{x}))^2 p(\mathbf{x}, t)d\mathbf{x} dt
$$

Using the average loss while using the squared loss function, the **optimal
solution $y$ is the conditional average**:

$$
y(\mathbf{x}0 = \int tp(t|\mathbf{x}) dt = E[t|x]
$$

**Another useful loss function is the Minkowski loss**:

$$
E[L] = \iint |t - y(\mathbf{x})|^q p(\mathbf{x}, t)d\mathbf{x} dt
$$

For $q=2$ we have the square loss, for $q=1$ is the conditional mean.

### Basis functions

**To consider non-linear functions, we can use non-linear basis functions**:

$$
y(\mathbf{x}, \mathbf{w}) =
  w_0 + \sum_{j=1}^{M-1} w_j \phi_j(\mathbf(x)) =
  \mathbf{w}^T \mathbf{\phi}(\mathbf{x})
$$

With $\mathbf{\phi}(\mathbf{x}) \in Mat(M, 1)$. Some examples of basis functions
are:

1. Polynomial: $\phi_j(x) = x^j$
2. Gaussian: $\phi_j(x) = \exp(-\frac{(x-\mu_j)^2}{2\sigma^2})$
3. Sigmoidal: $\phi_j(x) = \frac{1}{1+\exp(\frac{\mu_j -x}{\sigma})}$

### Minimizing least squares

Given a data set with $N$ samples, let us consider the **following loss
function**:

$$
L(\mathbf{w}) = \frac{1}{2} \sum_{n=1}^{N} (y(\mathbf{x_n}, \mathbf{w}) - t_n)^2
$$

This is (half) the residual sum of squares ( **RSS** ), also known as sum of
squared errors. It can also be written as the sum of the $l_2$-norm of the
vector of residual errors: $RSS(\mathbf{w}) = \|\epsilon^2\|$.

Since we are working with **linear models**, we **do not have any local
minimum.** This means that when we find a minimum we are sure it is the optimal.

We can write the **RSS in matrix form using the design matrix** $\mathbf{\Phi}$
defined as

$$
\mathbf{\Phi} = (\phi(\mathbf{x}_1), \ldots, \phi(\mathbf{x}_N))^T
$$

This means that the loss can be written as:

$$
L(\mathbf{w}) = \frac{1}{2} RSS(\mathbf{w}) =
  \frac{1}{2}(\mathbf{t} - \mathbf{\Phi w})^T (\mathbf{t} - \mathbf{\Phi w})
$$

We compute the first and second derivatives.

$$
\frac{\partial L(\mathbf{w})}{\partial\mathbf{w}} =
  -\mathbf{\Phi}^T (\mathbf{t}-\mathbf{\Phi w})
\quad
\frac{\partial^2 L(\mathbf{w})}{\partial\mathbf{w}\partial\mathbf{w}^T} =
  \mathbf{\Phi}^T \mathbf{\Phi}
$$

We can then **obtain the optimal waste by equaling to 0 the first derivative**
and obtaining:

$$
\mathbf{\hat{w}}_{OLS}
  = (\mathbf{\Phi}^T\mathbf{\Phi})^{-1}\mathbf{\Phi}^T \mathbf{t}
  = \mathbf{\Phi}^\dagger\mathbf{t}
$$

Assuming that $\mathbf{\Phi}^T\mathbf{\Phi}$ is **non singular**. We call the
$\mathbf{\Phi}^\dagger$ the Penrose-Moore pseudo inverse.

The $\mathbf{\Phi}^T\mathbf{\Phi}$ matrix is **non singular when**:

1. We have **linearly dependent features**
2. It is **fat**, i.e we have more features than samples ($M>N$). This is the
   major limitation of the method.

The second derivative is the Hessian matrix of $L(\mathbf{w})$. Since it is
defined semi-positive (due to being a quadratic form), it assures us that all
eigenvalues are positive, thus that the function has positive concavity and only
one minimum.

The computation complexity of the optimal weights is dominated by the inversion
of the matrix. Therefore it is $\mathcal{O}(NM^2 + M^3)$.

### Gradient optimization

Gradient optimization can be used if it is too computationally expensive to
compute the closed form.

If the loss function can be expressed as a sum over samples, we can be more
efficient:

$$
\begin{gathered}
  (L(x) = \sum_n L(x_n)) \\
  w^{k+1} = w^k - a^k\gradient L(x_n) \\
  w^{k+1} = w^k - a^k (w^k^T\phi(x_n) - t_n)\phi(x_n)
\end{gathered}
$$

Where $k$ is the iteration and $\alpha$ is the learning rate. For convergence,
we need:

$$
\begin{gathered}
  \sum_k^\infty a^k = +\infty \\
  \sum_k^\infty a^k^2 < +\infty \\
\end{gathered}
$$

A common $\alpha$ is $1/k$.

## Final note

Course is too fast to keep up accurate notes. Instead I will resort to sloppily
annotated PDFs and the course book (Pattern Recognition and Machine Learning,
Bishop).
