# Computer graphics

## Coordinates

Current graphics adapter can show 3 things: **points, lines and filled triangles**.
**Any other shape must be composed by these 3 primitives**.

**Primitives draw and connect points on the screen identified by a set of
coordinates**, defined with a vector of two components. These **coordinates are
integer number whose units are pixels. These coordinates are called pixel
coordinates**.

### Pixel coordinates

The coordinates system is **Cartesian**, with **origin on the top-left of the screen.**
The **horizontal** direction is the **x-axis**, while the **vertical** one is the **y-axis**.
The **y-axis is reversed**: it goes from the top to the bottom of the screen.

The coordinates of the two coordinates are **from $[0;s_w-1]$ and $[0;s_h-1]$** where
$s_w$ and $s_h$ are respectively the horizontal and vertical resolutions of the
screen.

**For objects that have a position with coordinates greater than the maximum, we need
to clip the objects**. If we continue drawing without clipping we may write to
some unallocated memory space, causing problems.

### Normalized screen coordinates

To **remove the dependency on the knowledge of the screen resolution**, we use
**normalized screen coordinates**. This coordinate space **allows us to display
correctly the same scene on different aspect rations or pixel dimensions**
(square vs rectangular).

We use coordinates in the **range of $[-1;1]$**. This means that the **center of the
display (point $(0;0)$) is also the origin of the system**.

In **OpenGL**, both **directions go in the same direction** ($(-1;-1)$ in the lower
left, $(1;1)$ in the upper right; this means that the y-axis goes up), while
**Vulkan maintains the convention of the pixel coordinates** (y-axis goes down).

If we know the size of our draw area, we can **derive** the normalized coordinates
using the following **transformation**:

$$\begin{aligned}
  x_s &= \frac{(s_w-1)*(x_n=1)}{2} \\
  y_s &= \frac{(s_h-1)*(y_n=1)}{2} \\
\end{aligned}$$


## Graphics primitives

The simplest primitive is the point. Drawing a point is equivalent to setting a
pixel on the screen. The syscall to draw a pixel is called
`plot(x_norm, y_norm)`.

The line primitive connects two points on the screen with a straight line. It
requires the coordinates of two points.

The triangle is the basis of 3D graphics. They are specified with the coordinates
of the 3 vertices. The graphics adapter will fill the surface of the triangle
with some colors.

## 3D images

In order to represent objects in a 3D space, an appropriate **coordinate system**
must be chosen. We will use a special system, called **homogeneous coordinates**. In
this system, a point is characterized by **four values**: $x,y,z,w$. The **first
three are the usual 3D coordinates**, while the **fourth defines a scale**, that is a
**unit of measure** used by the other three coordinates.

Since we use 4D system to represent a 3D system, it means that **we have an
infinite number of coordinates that identify the same position**. In particular,
**all tuples of four values that are linearly dependent represent the same point
in 3D space**. Due to this, we will **assume that the "real" position of the point
is the one with** $w = 1$.

### Affine transforms

The affine transforms are usually categorized into 4 categories: translations,
scaling, rotation and shear.

To transform an object, we apply the same transformation to all its points. The
transformed object is obtained by reconstructing the geometric primitives with
the new points.

Affine transformations in homogeneous coordinates can be **expressed with a
4x4 matrix**. The **transformed point** can be expressed using **matrix multiplication**:
$p' = (M \cdot p^T )^T$. We could also have written the transformation as $p
\cdot M^T)$, it is a matter of convention. **We will use the matrix-on-the-left
form. We will also use column vectors, dropping the transpose operators**. _Many
libraries work better with matrix-on-the-right transforms, so be careful_.

**NOTE**: whit the **matrix-on-the-right**, all **transformation matrices will be
transposed**.

#### Translation

Takes one object and moves it of a specified $d$ amount.

$$
T(d_x, d_y, d_z) =
\begin{bmatrix}
  1 & 0 & 0 & d_x \\
  0 & 1 & 0 & d_y \\
  0 & 0 & 1 & d_z \\
  0 & 0 & 0 & 1 \\
\end{bmatrix}
$$

#### Scaling

Scaling scales the size of an object, while maintaining constant position and
its orientation. By choosing appropriate parameters, scaling can be used to
enlarge, shrink, deform, mirror or flatten objects.

In a scaling transformation, the origin of the element does not change. **We will
initially assume that the origin of the scaling is the origin of the 3D space**.

Proportional scaling scales all axes proportionally. Given $s$;

- $s > 1$ the object is enlarged by a factor of $s$
- $0 < s < 1$ the object is shrank by a factor of $1/s$

Non proportional scaling is the same, however on a per-axis basis.

$$
S(s_x, s_y, s_z) =
\begin{bmatrix}
  s_x & 0   & 0   & 0 \\
  0   & s_y & 0   & 0 \\
  0   & 0   & s_z & 0 \\
  0   & 0   & 0   & 1 \\
\end{bmatrix}
$$

Proportional scaling happens when all $s_\star$ coefficients are equal.

##### Mirroring

**Mirroring can be obtained by using negative scaling factors**. Mirroring can be
planar, axial or central. Initially we will assume that the mirroring occurs
around a plane/axis/center that passes through the origin.

1. **Planar**:  $s_x = -1, s_y = 1, s_z = 1$ (obtained by assigning a negative value
   for the axis perpendicular to the plane; in this example we mirrored around
   the yz-plane);
1. **Axial**:   $s_x = -1, s_y = 1, s_z = -1$ (obtained by assigning a negative
   value to all but one axis; in this example we mirrored around the y-axis);
1. **Central**: $s_x = -1, s_y = -1, s_z = -1$ (changes all the sign).

**Scaling can be combined with mirroring**.

##### Flattening

If the **scaling factor of one direction is zero**, then the object will be
flattened along that plane. **Flattening can create problems** because setting all
scaling factors to zero makes the **matrix non invertible**. This requires extra
work and such **will not be accounted for during the course**.

#### Rotation

Rotation varied the orientation of an object, leaving its position and size
unchanged. Rotations will be performed around an axis. For now, we will **consider
rotation around the x, y and z axes**.

Rotation around the z-axis can be expressed as:

$$
\begin{cases}
  x' &= x\cdot\cos\alpha - y\cdot\sin\alpha \\
  y' &= x\cdot\sin\alpha + y\cdot\cos\alpha \\
  z' &= z \\
\end{cases}
$$

We can see that the new coordinates depend on the values of the old coordinates.

Using trigonometry, we can represent the rotations around different axes as:

$$
\begin{gathered}
  R_x(\alpha) =
  \begin{bmatrix}
    1 & 0          & 0           & 0 \\
    0 & \cos\alpha & -\sin\alpha & 0 \\
    0 & \sin\alpha & \cos\alpha  & 0 \\
    0 & 0          & 0           & 1 \\
  \end{bmatrix} \\
  R_y(\alpha) =
  \begin{bmatrix}
    \cos\alpha  & 0 & \sin\alpha & 0 \\
    0           & 1 & 0          & 0 \\
    -\sin\alpha & 0 & \cos\alpha & 0 \\
    0           & 0 & 0          & 1 \\
  \end{bmatrix} \\
  R_z(\alpha) =
  \begin{bmatrix}
    \cos\alpha & -\sin\alpha & 0 & 0 \\
    \sin\alpha & \cos\alpha  & 0 & 0 \\
    0          & 0           & 1 & 0 \\
    0          & 0           & 0 & 1 \\
  \end{bmatrix}
\end{gathered}
$$

#### Shear

**It takes an objects and bends it in one direction. It is performed along an axis
and has a center**.

The direction of distortion is specified by a vector $h$. Again, we have three
different matrices expressing shearing along x, y or z.

$$
\begin{gathered}
  H_x(h_y, h_z) =
  \begin{bmatrix}
    1   & 0 & 0 & 0 \\
    h_y & 1 & 0 & 0 \\
    h_z & 0 & 1 & 0 \\
    0   & 0 & 0 & 1 \\
  \end{bmatrix} \\
  H_y(h_x, h_z) =
  \begin{bmatrix}
    1 & h_x & 0 & 0 \\
    0 & 1   & 0 & 0 \\
    0 & h_z & 1 & 0 \\
    0 & 0   & 0 & 1 \\
  \end{bmatrix} \\
  H_z(h_x, h_y) =
  \begin{bmatrix}
    1 & 0 & h_x & 0 \\
    0 & 1 & h_y & 0 \\
    0 & 0 & 1   & 0 \\
    0 & 0 & 0   & 1 \\
  \end{bmatrix}
\end{gathered}
$$

#### Transformation matrix

We can see that the **transformation matrix always has the last row equal** to
$[0,0,0,1]$. This is not a coincidence: it is necessary to not modify the $w$
coordinate. **The last column**, on the other hand, always **encodes a translation**.

This means we can **subdivide** our transformation matrix **into blocks**:

$$
M = \left[\begin{array}{c|c}
  M_R & d^T \\
  \hline
  0   & 1   \\
\end{array}\right]
$$

The **$M_R$ 3x3 matrix encodes a rotation/scaling/shear**. Each **column of this
matrix tells us the directions and sizes of each new axis in the old reference
system**.

#### Inversion of transformations

Transformations can be **inverted to reverse a point to its previous position**.
This operation **can be done only if the transformation matrix is invertible**. Our
transformation matrix **can be inverted if the upper 3x3 block is invertible**,
since the last row is $[0, 0, 0, 1]$.

In the general case, the **transformation is not invertible if**:

1. One **axis becomes of zero** length
2. **Two axis become identical**
3. One axes becomes a **linearly dependent** of the other two

For the transformations we seen, **only scaling can cause problems**.

Inverting can be done only on the 3x3 block and **use the formulas for block
matrices** to fill out the rest.

$$
M^{-1} = \left[\begin{array}{c|c}
  M_R^{-1} & -M_R^{-1} \cdot d^T \\
  \hline
  0   & 1   \\
\end{array}\right]
$$

For the special patterns we described previously we have **pre-calculated matrix
patterns**:

1. **Translation**: $T(d_x, d_y, d_z)^{-1} = T(-d_x, -d_y, -d_z)$
2. **Scaling**: $S(s_x, s_y, s_z)^{-1} = S(1/s_x, 1/s_y, 1/s_z)$
   **Note**: inversion can be done only if $s \neq 0$
3. **Rotation**: see `L03` slide 9
4. **Shear**: simply invert the shearing factor

#### Composition

During the creation of a scene, an object is subject to several
transformations. The application of a sequence of transformation is called
composition. Moreover, rotations among arbitrary axes and scaling with different
centers can be performed by composing different transformations.

Thanks to the properties of matrix product, composition of transformations
can be be done in a very efficient way.

**Transformations are chained by multiplying them from right to left (think like
function composition)**. For the other convention, everything is in reverse.

Remember that matrix multiplication is not commutative, therefore **the order in
which we apply a transformation matters a lot**.

##### Rotations around an arbitrary axis/center

Let us first imagine that **the rotation axis still passes through the origin**.
This means that we can express the position of the axis using 3 angles $\alpha$,
$\beta$ and $\gamma$: they are respectively roll, yaw and pitch.

We will **express our rotation as a composition of different rotations**:

1. Rotation of $-\beta$ around $y$
2. Rotation of $-\gamma$ around $z$
3. Rotation of $\alpha$ around $x$
4. Rotation of $\gamma$ around $y$
5. Rotation of $\beta$ around $z$

Effectively we **first aligned the object's axis with x, did the rotation then
re-rotated the object back**.

If the **axis does not pass through the origin**, we **need to first reverse the
translation**, rotate and then reapply the translation.

##### Transformations around an arbitrary axis/center

The **same concept** of arbitrary rotation can be applied to all transformations
around a non-origin center: we **reverse the translation, the we apply the
transformation and finally we reapply the translation**.

We have an **alternative closed form to compute the rotation around arbitrary axes
by using a unit vector. For the formula+paper see `L03` slide 25**.

By using the **associative** property of matrix multiplication, we can
**compute all the transformation and then multiply by the point to transform**. The
**transformation matrix can be computed once for each object and then applied it to
each vertex**.

We can also use the properties on matrix inversion to compute the **inversion of
the mega-rotation matrix**, **reducing it to only changing the sign of the input
angle**.

#### GLM

GLM is simple linear algebra that we can use to simplify matrix operation for
graphics. It has been created for openGL, but it also works for other contexts.

We will not go in depth, but we will explain a little bit how it works.

Includes:

- `glm/glm.hpp`: the main component
- `glm/gtc/matrix_transforms.hpp`: the extension that contains the functions to
  create transform matrices

`glm::mat4` is used to define the 4x4 matrices (`glm::mat3` for 3x3). We can
instantiate a new matrix with elements by specifying elements per-column.
`glm::mat4(1)` creates an identity matrix. Elements are accessed using array
notation `[j][i]`, specifying first the column then the row.

Products are computed using the overloaded `*` operator (like the other standard
matrix operations), inversion using the `inverse()` function while transposition
using `transpose()`.

`glm::vec{3,4}` can be used for respectively 3 and 4 component vectors.

Transformation matrices can be generated using the following functions:

- Translation: `gml::tanslate()`
- Scale: `gml::scale()`
- Rotate: `gml::rotate()`
- Shearing requires a special header and follows what the other functions do

It is convenient to force angles in radians by defining `GLM_FORCE_RADIANS`
