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

