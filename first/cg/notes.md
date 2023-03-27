# Computer graphics

## Coordinates

Current graphics adapter can show 3 things: **points, lines and filled
triangles**. **Any other shape must be composed by these 3 primitives**.

**Primitives draw and connect points on the screen identified by a set of
coordinates**, defined with a vector of two components. These **coordinates are
integer number whose units are pixels. These coordinates are called pixel
coordinates**.

### Pixel coordinates

The coordinates system is **Cartesian**, with **origin on the top-left of the
screen.** The **horizontal** direction is the **x-axis**, while the **vertical**
one is the **y-axis**. The **y-axis is reversed**: it goes from the top to the
bottom of the screen.

The coordinates of the two coordinates are **from $[0;s_w-1]$ and $[0;s_h-1]$**
where $s_w$ and $s_h$ are respectively the horizontal and vertical resolutions
of the screen.

**For objects that have a position with coordinates greater than the maximum, we
need to clip the objects**. If we continue drawing without clipping we may write
to some unallocated memory space, causing problems.

### Normalized screen coordinates

To **remove the dependency on the knowledge of the screen resolution**, we use
**normalized screen coordinates**. This coordinate space **allows us to display
correctly the same scene on different aspect rations or pixel dimensions**
(square vs rectangular).

We use coordinates in the **range of $[-1;1]$**. This means that the **center of
the display (point $(0;0)$) is also the origin of the system**.

In **OpenGL**, both **directions go in the same direction** ($(-1;-1)$ in the
lower left, $(1;1)$ in the upper right; this means that the y-axis goes up),
while **Vulkan maintains the convention of the pixel coordinates** (y-axis goes
down).

If we know the size of our draw area, we can **derive** the normalized
coordinates using the following **transformation**:

$$
\begin{aligned}
  x_s &= \frac{(s_w-1)*(x_n=1)}{2} \\
  y_s &= \frac{(s_h-1)*(y_n=1)}{2} \\
\end{aligned}
$$

### Homogeneous coordinates

In order to represent objects in a 3D space, an appropriate **coordinate
system** must be chosen. We will use a special system, called **homogeneous
coordinates**. In this system, a point is characterized by **four values**:
$x,y,z,w$. The **first three are the usual 3D coordinates**, while the **fourth
defines a scale**, that is a **unit of measure** used by the other three
coordinates.

Since we use 4D system to represent a 3D system, it means that **we have an
infinite number of coordinates that identify the same position**. In particular,
**all tuples of four values that are linearly dependent represent the same point
in 3D space**. Due to this, we will **assume that the "real" position of the
point is the one with** $w = 1$.

## Graphics primitives

The simplest primitive is the point. Drawing a point is equivalent to setting a
pixel on the screen. The syscall to draw a pixel is called
`plot(x_norm, y_norm)`.

The line primitive connects two points on the screen with a straight line. It
requires the coordinates of two points.

The triangle is the basis of 3D graphics. They are specified with the
coordinates of the 3 vertices. The graphics adapter will fill the surface of the
triangle with some colors.

## Affine transforms

The affine transforms are usually categorized into 4 categories: translations,
scaling, rotation and shear.

To transform an object, we apply the same transformation to all its points. The
transformed object is obtained by reconstructing the geometric primitives with
the new points.

Affine transformations in homogeneous coordinates can be **expressed with a 4x4
matrix**. The **transformed point** can be expressed using **matrix
multiplication**: $p' = (M \cdot p^T )^T$. We could also have written the
transformation as $p
\cdot M^T)$, it is a matter of convention. **We will use the
matrix-on-the-left form. We will also use column vectors, dropping the transpose
operators**. _Many libraries work better with matrix-on-the-right transforms, so
be careful_.

**NOTE**: whit the **matrix-on-the-right**, all **transformation matrices will
be transposed**.

### Translation

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

### Scaling

Scaling scales the size of an object, while maintaining constant position and
its orientation. By choosing appropriate parameters, scaling can be used to
enlarge, shrink, deform, mirror or flatten objects.

In a scaling transformation, the origin of the element does not change. **We
will initially assume that the origin of the scaling is the origin of the 3D
space**.

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

#### Mirroring

**Mirroring can be obtained by using negative scaling factors**. Mirroring can
be planar, axial or central. Initially we will assume that the mirroring occurs
around a plane/axis/center that passes through the origin.

1. **Planar**: $s_x = -1, s_y = 1, s_z = 1$ (obtained by assigning a negative
   value for the axis perpendicular to the plane; in this example we mirrored
   around the yz-plane);
1. **Axial**: $s_x = -1, s_y = 1, s_z = -1$ (obtained by assigning a negative
   value to all but one axis; in this example we mirrored around the y-axis);
1. **Central**: $s_x = -1, s_y = -1, s_z = -1$ (changes all the sign).

**Scaling can be combined with mirroring**.

#### Flattening

If the **scaling factor of one direction is zero**, then the object will be
flattened along that plane. **Flattening can create problems** because setting
all scaling factors to zero makes the **matrix non invertible**. This requires
extra work and such **will not be accounted for during the course**.

### Rotation

Rotation varied the orientation of an object, leaving its position and size
unchanged. Rotations will be performed around an axis. For now, we will
**consider rotation around the x, y and z axes**.

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

### Shear

**It takes an objects and bends it in one direction. It is performed along an
axis and has a center**.

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

### Transformation matrix

We can see that the **transformation matrix always has the last row equal** to
$[0,0,0,1]$. This is not a coincidence: it is necessary to not modify the $w$
coordinate. **The last column**, on the other hand, always **encodes a
translation**.

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

### Inversion of transformations

Transformations can be **inverted to reverse a point to its previous position**.
This operation **can be done only if the transformation matrix is invertible**.
Our transformation matrix **can be inverted if the upper 3x3 block is
invertible**, since the last row is $[0, 0, 0, 1]$.

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
2. **Scaling**: $S(s_x, s_y, s_z)^{-1} = S(1/s_x, 1/s_y, 1/s_z)$ **Note**:
   inversion can be done only if $s \neq 0$
3. **Rotation**: see `L03` slide 9
4. **Shear**: simply invert the shearing factor

### Composition

During the creation of a scene, an object is subject to several transformations.
The application of a sequence of transformation is called composition. Moreover,
rotations among arbitrary axes and scaling with different centers can be
performed by composing different transformations.

Thanks to the properties of matrix product, composition of transformations can
be be done in a very efficient way.

**Transformations are chained by multiplying them from right to left (think like
function composition)**. For the other convention, everything is in reverse.

Remember that matrix multiplication is not commutative, therefore **the order in
which we apply a transformation matters a lot**.

#### Rotations around an arbitrary axis/center

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

#### Transformations around an arbitrary axis/center

The **same concept** of arbitrary rotation can be applied to all transformations
around a non-origin center: we **reverse the translation, the we apply the
transformation and finally we reapply the translation**.

We have an **alternative closed form to compute the rotation around arbitrary
axes by using a unit vector. For the formula+paper see `L03` slide 25**.

By using the **associative** property of matrix multiplication, we can **compute
all the transformation and then multiply by the point to transform**. The
**transformation matrix can be computed once for each object and then applied it
to each vertex**.

We can also use the properties on matrix inversion to compute the **inversion of
the mega-rotation matrix**, **reducing it to only changing the sign of the input
angle**.

### GLM

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

## Projections

Projections **"flatten" our 3-dimensional space so that it can be represented on
a 2d screen**. The **2D representation of a 3D object is defined by the
intersection of a set of projection rays with a surface, usually a plane called
the projection plane**.

One important property of our projections is that **straight lines in the source
space will be converted into lines in the projection**. With non-planar
projection, this is not the case any more.

Using the above property, **we can represent objects by projecting only the
"extreme" points, not all of them. Then we can reconnect the projected edges and
obtain the projection**.

We will see parallel and perspective projections:

1. In **parallel projection all rays are parallel to the same direction**.
2. In **perspective projection all rays converge to a point** called the center
   of projection.

For both our projection, **a point on the screen corresponds to an infinite
amount of coordinates in the space. This a consequence of losing a dimension**.
In parallel projections, all points that pass through a line parallel to the
projection ray are mapped to the pixel. In perspective projection, all points
that are aligned with both the projected pixel and the center of projection are
mapped to the same location.

In 3D graphics, **projections convert "world coordinates" into 3D Normalized
screen coordinates**. With **world coordinates we define a set of coordinates
that positions objects into our 3D space**:

1. The **origin will be in the center of our screen**.
2. The **use a right-handed y-up system**: x goes to right, y to up and z
   towards the viewer.

   Another very common approach is using a z-up system.

3. The **unit is chosen based on what we are drawing**. The important thing is
   that we are consistent.

To correctly sort surfaces, **we need to additionally store a "distance from
viewer" metric** that allows us to do the sorting.

**3D normalized screen coordinates have a third component**, which for Vulkan is
in the $[0;1]$ range.

Considering how we defined our world coordinates, **we have that everything we
see has negative z coordinate**.

### Aspect ratio

The **proportions of the physical screen are called aspect ratio**. The
**dividends of the aspect ratio of the screen are in metric units**, not in
pixels. **If the pixels are square** (very common assumption), **both metrical
units and pixels would lead to the same result**. If pixels are not square, only
the actual display proportions can create images that are not distorted.

**Normalized screen coordinates do not account for the aspect ratio**: the
**projection matrix takes care of this factor and properly scales the images**
to make them appear with the correct proportions.

### Parallel projection

The screen imposes **boundaries on what we can see**: we have limits on what we
can see on the sides, but also on the depth (we do not want to show things that
are too close or too far).

The **depth limits are delimited by two planes**: the **near** plane (the plane
with the closest z component) and the **far** plane.

The **projection is defined such that the top-bottom-left and right borders are
on the corresponding borders of the normalized space and that the two clip
planes are inside the normalized space**.

Since we use homogeneous coordinates, **we can express the projection with a
matrix product**.

Let us define some positions in the world coordinates:

1. $l$ and $r$ ($r>l$) are the x-coordinates of the horizontal borders
2. $t$ and $b$ ($t>b$) are the y-coordinates of the vertical borders
3. $-n$ and $-f$ are the z-coordinate of the clip planes

The projection matrix is **computed in three steps**:

1. First **we move the center of the projection box at the near plane origin**
   with a translation $T_{ort}$

   $$
    \begin{bmatrix}
      1 & 0 & 0 & -\frac{r+l}{2} \\
      0 & 1 & 0 & -\frac{t+b}{2} \\
      0 & 0 & 1 & -\frac{r+l}{2} \\
      0 & 0 & 0 & 1 \\
    \end{bmatrix}
   $$

2. The second step **normalizes the coordinates between 0 and 1**:

   $$
    \begin{bmatrix}
      \frac{2}{r-l} & 0 & 0 & 0 \\
      0 & \frac{2}{t-b} & 0 & 0 \\
      0 & 0 & \frac{1}{f-n} & 0 \\
      0 & 0 & 0 & 1 \\
    \end{bmatrix}
   $$

3. The last step **corrects the direction of the y and z axis**

   $$
    \begin{bmatrix}
      1 & 0 & 0 & 0 \\
      0 & -1 & 0 & 0 \\
      0 & 0 & -1 & 0 \\
      0 & 0 & 0 & 1 \\
    \end{bmatrix}
   $$

The result of the composition is:

$$
\begin{bmatrix}
  \frac{2}{r-l} & 0 & 0 & \frac{r+l}{l-r} \\
  0 & \frac{2}{b-t} & 0 & \frac{t+b}{t-b} \\
  0 & 0 & \frac{1}{n-f} & \frac{n}{n-f} \\
  0 & 0 & 0 & 1 \\
\end{bmatrix}
$$

In order to not output distorted images, **our bounds need to be consistent with
the aspect ration of the monitor**.

In most cases, **the projection box is centered in the origin both horizontally
and vertically: if this happens, the half width $w$, the clip planes $n$ and $f$
and the aspect ratio $a$ are enough to define the projection**:

$$
\begin{bmatrix}
  \frac{1}{w} & 0 & 0 & 0 \\
  0 & \frac{-a}{w} & 0 & 0 \\
  0 & 0 & \frac{1}{n-f} & \frac{n}{n-f} \\
  0 & 0 & 0 & 1 \\
\end{bmatrix}
$$

```txt
w             -w
+--------------+  w/a
|              |
|              |
+--------------+ -w/a
```

If we consider the **near plane at 0 ($n=0$) we can even avoid the
translation**.

**At the end** of the projection process, we **need to convert our result to
Cartesian coordinates by dividing by the 4th coordinate. In the case of parallel
projection this last component will always be one**, so it can be simply
discarded.

> In GLM we have the `glm::ortho` function. Since the library was created for
> OpenGL, we need to change the axes of the ortho matrix to obtain a Vulkan
> compatible one.
>
> Since it is very simple to create the matrix, we can simply roll our own
> function.

To make stuff **appear more three dimensional** with parallel projections we
**slightly tilt the view/changing the orientation of the projection plane**.

#### Axonometric projections

Axonometric projections use the "rotate world" method.

**Axonometric projections where that have rays perpendicular to the projection
plane are called orthographic projections**. A **property** of axonometric
**projections is that the y axis is always vertical**.

We are going to see 3 main types:

- **Isometric**: all axes are 120 degrees distant. To obtain an isometric
  projection we need to first apply **two rotations**:

  1. $\pm 45$ degrees **around the y-axis**
  2. $\pm 35.26$ **around the x-axis**

  **Using different combination of signs, we obtain different representations of
  the isometric projections**.

- **Dimetric**: used a lot in retro-style games since it was **very easy to
  handle with integer math**; it has the same angle between y-z and y-x but
  different for x-z. To obtain this projection we do **two rotations**:

  1. $\pm 45$ degrees **around the y axis**
  2. $\alpha$ **around the x-axis**

- **Trimetric**: all three angles are different. It is obtained by:
  1. **An arbitrary** $\beta$ **rotation around the y-axis**
  2. **An arbitrary** $\alpha$ **rotation around the x-axis**

In **oblique projections, rays are parallel but oblique with respect to the
plane itself**. This has the effect of **keeping two of the three axes (usually
x and y) parallel to the screen; the third one is at an angle**.

The **length of the z axis can be maintained (Cavalier) or halved (cabinet)**.

Oblique projections can be applied by **applying a shear of modulo** $\rho$ and
**angle** $\alpha$ **along the z-axis before the orthogonal projection**. The
**shear factor will determine the angle of projection and whether it will be a
Cavalier or cabinet**.

### Perspective projections

Perspective projections **simulate perspective**. The **magnification effect
produced by perspective is due to the fact that all rays pass through the same
point**.

To simplify computation, let us **assume that the projection center is in the
origin**. The **projection plane** is located at a distance $d$ **on the z axis
from the projection center**. Our point is $y$ distant vertically from the
center. We can **compute the projected height** $y_s$ using **trigonometry**:
$y_s = \frac{d\cdot y}{z}$. With **the same reasoning**, we can calculate
$x_s = \frac{d\cdot x}{z}$.

The parameter $d$ is **the distance of the center from the projection plane**.
It can be used to **simulate the focal length of the lens of a camera**.
Changing $d$ we can simulate a zoom effect. **Parallel projections can be
obtained if we impose that** $d\to\infty$.

Thanks to homogeneous coordinates, perspective projection can be **obtained with
matrix-vector products**.

First we note that the considered world coordinate system is oriented the
opposite direction on the z-axis: this means that in our formula **we need to
invert the sign of** $z$. The resulting matrix is:

$$
\begin{bmatrix}
  d & 0 & 0  & 0 \\
  0 & d & 0  & 0 \\
  0 & 0 & d  & 0 \\
  0 & 0 & -1 & 0
\end{bmatrix}
$$

We notice that **the resulting vector does not have** $w=1$. This means that
**to obtain the Cartesian equivalent we need to divide by** $w$.

This method has the **problem of loosing depth information** since $z = -d$.
This does not allow us to define proper 3D normalized screen coordinates with a
$z_s$ component that reflects the distance of the point from the view plane.
**To solve this problem we can simply add a translation** of $1$ **along the z
axis**.

As for parallel projections, the visible area of the 3D world should be mapped
to 3D normalized screen coordinates. In the case of perspective, things are more
difficult **since our boundary is not anymore a simple cube, but a frustum**.

Let us call:

- $n$ the distance from the origin of the near plane.
- $l,r,t,b$ the coordinates of the left, right, top and bottom edges of the
  projection planes in the world space at the near plane.
- $f$ the distance from the origin of the far plane.

Since our visible space is not a cube, the **far plane's dimensions will be
different from those of the near plane**. Since **the coordinates of the border
of the screen are specified at the near plane, the value of $n$ corresponds to
the distance of the projection plane $d$**.

The **first step** is taking the previous translation and replacing $d$ with
$n$. Since the edges of the near plane are given at the near plane, we **compute
the projections of the top-left and bottom-right corners at the near plane**. We
also **need to compute the projected coordinate of a point at the far plane**
($z=-f$) to **determine the proper normalization of the z axis**. Now we must
apply **translation and scaling to bring the points of into the normalized
space**. **Finally, we can flip the y axis**. Since obtaining the relevant
matrices is just numbers and latex, I am lazy and I am not doing it.

Like with parallel projections, the **sizes of the borders need to be consistent
with the aspect ration of the monitor**: $r - l = a(t - b)$.

A **simpler way to express the parameters** of the projections is **using
photography related parameters**: $n$, $f$ and $\Theta$ **the vertical field of
view** (angle between top-most and undermost rays). Given that:

- $t = n\tan\frac{\Theta}{2}$
- $b = -n\tan\frac{\Theta}{2}$
- $l = -an\tan\frac{\Theta}{2}$
- $r = an\tan\frac{\Theta}{2}$

We can redo our matrices using only these three parameters.

> Like with `ortho`, GLM does provide functions (although made for OpenGL) for
> computing our functions:
>
> - `glm::frustum(l, r, b, t, n, f)` computes the perspective projection
>   specifying the boundaries
> - `glm::perspective(fov, a, n, f)` computes the perspective projection using
>   the "photographic" set of parameters

## View matrix

Until now, all our projections have been anchored to one point. **How can we
draw objects as seen from an arbitrary point in space**?

For ease, le tu consider the following compass (from the top):

```txt
      -z
      ^
      |
-x <--+--> +x
      |
      v
      +z
```

The projection matrices assume that: projection plane is parallel to the $xy$
plane and that we are facing "north". We can **re-orient our view by adding a
set of additional transformations before our projection**.

We will focus on perspective, but the same works for parallel projections.

Let us imagine that our projection point is a camera with an orientation. This
camera is characterized by its position, the direction its aiming and the angle
around this direction. **The projection matrices seen as far compute the view of
the camera initially positioned in the origin and aiming along the negative
z-axis**. We can consider our camera as a 3D object. **We will call the matrix
that moves the camera from the origin to its final position "camera matrix"**
$M_c$.

If **we apply the inverse of $M_c$ to all the object in the scene, we obtain a
new 3D world where the projection plane is placed exactly as required by the
projection matrices**. $M_c^{-1}$ is called the "view matrix". The view matrix
must be applied before the projection.

### Creating a view matrix: look-in-direction

The user directly controls the camera position and the view direction.

The position of the camera is given in world coordinates. **The direction where
the camera is looking is specified with three angles**:

1. The "compass" direction ($\alpha$), also called **yaw**:
   - $\alpha = 0$: north
   - $\alpha = 90$: west
   - $\alpha = 180$: south
   - $\alpha = 270$: east (can be also -90)
   - It is a **rotation around the $y$ axis**
2. The elevation ($\beta$), also called **pitch**:
   - $\beta > 0$: look up
   - $\beta < 0$: look down
   - It is a **rotation around the $x$ axis**
3. The **roll** ($\rho$):
   - $\rho > 0$: counter-clockwise roll
   - it is a **rotation around the $z$ axis**

These rotations must be **done in a specific order** (we will come back later on
the why):

$$
\begin{gathered}
M_c = T(c_x, c_y, c_z) R_y(\alpha) R_x(\beta) R_z(\rho) \\
M_c^{-1} = R_z(-\rho) R_x(-\beta) R_y(\alpha) T(-c_x, -c_y, -c_z) \\
\end{gathered}
$$

> GLM does not provide any special functions, so we need to roll our own.

### Creating a view matrix: look-at

In the look-at we want to **follow a specific object**. We have a
**translation**, as before but instead of the angles we have **the position of
the target point**. This technique also requires the **up vector**, i.e. the
direction perpendicular to the ground $[0, 1, 0]$ (the up vector can be changed
to achieve some interesting effects). The need of the up vector is to align the
camera's frame with the "horizon".

The first step is to **compute the direction of the camera in world
coordinates**, then we can use the corresponding information to build the camera
matrix as before.

To compute the rotation we **compute the axes in the transformed space**:

- The new **z-axis (negative) should be the vector that connects the camera with
  the point looked at**.

  $$
    v_z = \frac{c - a}{|c-a|}
  $$

- The new **x-axis must be perpendicular to both the new z-axis and the
  up-vector**. It can be computed using the **normalized cross-product**.

  $$
  v_z
    = \frac{u \times v_z}{|u \times v_z|}
  $$

  Note that the cross product is zero if the two axis are aligned. In this case
  we can select a random orientation for the x axis.

- The new y-axis should be **perpendicular to the other two**. We calculate it
  like we did for the x-axis

  $$
    v_y = v_z \times v_x
  $$

  Since the two axes are by construction perpendicular, we do not need to
  normalize.

The camera and view matrices can be created as follows:

$$
\begin{gathered}
  M_c = \left[\begin{array}{ccc|c}
    v_x & v_y & v_z & c \\
    \hline
    0 & 0 & 0 & 1 \\
  \end{array}\right] \\
  M_v = \left[\begin{array}{c|c}
    (R_c)^T & -(R_c)^T c \\
    \hline
    \mathbf{0} & 1 \\
  \end{array}\right] \\
\end{gathered}
$$

> cross product and normalization can be done with `glm::cross` and
> `glm::normalize` function.
>
> glm does offer the `glm::lookAt` function that create this matrix for us
> starting from three `vec3` representing the center of the camera, the point it
> targets and the up vector.

To implement **roll**, we can do two things:

1. We can **rotate the up vector**
2. We can **add a rotation** of $\rho$ around the **z-axis**.

### Navigation

A navigation model update procedure receives up to six floating point values in
the $[0,1]$ range:

1. Three movement axes
2. Three rotation axes

The input is taken from the operating system using libraries like GLFW or SDL.

## World matrix

One of the main features of 3D computer graphics is placing and moving objects
in the virtual space. **Movement of the objects is usually performed with a
transformation matrix: the world matrix** $M_w$.

**Every object is characterized by a set of local coordinates**: the positions
of the object's points in the space where it was created. **The world matrix
transforms each object's local coordinates into world coordinates**. It is also
important that a **model is modeled considering as the origin the point that
most represents its position**.

The world matrix applies a series of translations, rotations (and possibly
scaling or shears) to the local coordinates.

For positioning, we can simply do a translation. For the correct result,
**translations should be always applied last**. If we want to change the scale
of an object, we apply a scale transformation. **Scaling must always be the
first. Rotation should be done in the middle of the two**.

### Euler angles

**Which order of rotations should we use to ensure a natural transformation?**
Let us consider three parameters: roll, pitch and yaw (we already seen them
previously).

Euler angles were introduced for **z-up coordinate** systems. This explanation
will refer to this system.

Like with the origin, the modeler should help us by creating a model that is
facing along the positive x axis, with the side aligned to the y-axis and the
vertical line along the z axis.

In this system, we have that:

1. **Roll** is the rotation around the **x-axis**. (positive turns clockwise)
2. **Pitch** is the rotations along the **y-axis**. (positive turns down)
3. **Yaw** is the rotation along the **z-axis**. (positive rotates towards
   north, 0 is east)

With this convention, our rotations are done in the alphabetic order of the
axis: x, y and z. For different axes conventions, we always need to follow the
**Roll-Pitch-Yaw order**.

A rotation defined by the Euler Angles, is **perfect for "planar" movements**,
like the one available in a driving simulation or in an FPS. However they are
not the proper solution for applications such as flight or space simulators
since they can **suffer a problem known as Gimbal Lock: it is the loss of one
degree of motion when two of the three gimbals are in a parallel
configuration**.

### Quaternions

A solution to the Gimbal lock problem is **rethinking our representation of
rotations**.

**Quaternions are an extensions of complex numbers that have three imaginary
components**:

$$
  a + ib + jc + kd
$$

The three imaginary components are called the **_vector part_** and must
**respect the following relation**:

$$
  i^2 = j^2 = k^2 = ijk = -1
$$

From these rules, we can **define a complete algebra**, see slide 41 of lecture
07 for the complete formulas.

**Unitary quaternions are enough to encode rotations**. Let us consider a
rotation of an angle $\theta$ around an axis oriented along a unitary vector
$v = (x,y,z)$. This rotation can be **represented by the following quaternion**:

$$
  q = \cos\frac{\theta}{2} + \sin\frac{\theta}{2}(ix + jy + kz)
$$

Since $v$ is unitary, $q$ is also unitary.

Unitary quaternions can be **directly converted to rotation matrices** with the
following formula:

$$
  R(q) = \begin{bmatrix}
    1-2c^2 - 2d^2 & 2bc + 2ad       & 2bd - 2ac      & 0 \\
    2bc - 2ad     & 1 - 2b^2 - 2d^2 & 2cd + 2ab      & 0 \\
    2bd - 2ac     & 2cd - 2ab       & 1 - 2b^2 -2c^2 & 0 \\
    0             & 0               & 0              & 1 \\
  \end{bmatrix}
$$

If $q_1$ and $q_2$ are two quaternions that encode two different rotations,
their **products encodes the composed transform**. We can **transform a set of
Euler angles into a quaternion** using the formulas on slide 46 of lecture 7.

Like with transformations, the **product between quaternions is not
commutative**.

**There isn't a direct formula to transform a quaternion into the equivalent
Euler angles**.

#### Usage

When a program has to work with complex rotations, we usually internally store
the quaternion and convert it to a rotation matrix every time we compute the
transform.

Even relative changes in the direction of an object are encoded using a
$\Delta q$ that expresses the direction and entity of rotation. **Due to the
non-commutativity of quaternions we have that**:

- $\Delta q \cdot q$ results in a rotation in **world space** (i.e. using the
  axes of the current world coordinates)
- $q \cdot \Delta q$ results in a rotation in **local space** (i.e. using the
  axes of the object coordinates)

> To use quaternion functions in GLM we need to import `glm/gtc/quaternion.hpp`.
> Quaternions can be specified in three ways:
>
> 1. From Euler angles (rarely used, if we want to use it, we need to manually
>    apply the three rotations in the correct order).
> 2. Specifying the scalar and then the imaginary parts.
> 3. From the angle of rotation and the axis direction
>
> The scalar part is the `.w` component, while the imaginary parts are
> `x, y, z`.
>
> We can create a rotation matrix by simply passing it the corresponding
> quaternion.
>
> The normalize function is also defined for quaternions.
>
> The extended functions allow for more operations, however they are out of
> scope.

## Meshes

**3D objects are not stored as a collection of 3D points, since this would
require too much memory**. However, what we worked with until now is using 3D
points.

We store an object geometry using **mathematical models that represent surfaces
through a set of parameters** (computational geometry is the field). Many
approaches have been developed, the most common are:

1. **Meshes (polygonal surfaces)**
2. Hermite surfaces
3. NURBS (Non-Uniform Rational B-splines)
4. HSS (Hierarchical Subdivision Surfaces)
5. Metaballs

Each of this has its own features and limitations. However all models will be
converted into meshes when rendered, thus we will only look at them.

**Polygonal surfaces are objects that can be described by a set of contiguous
polygons. Due to special rendering tricks, these polygonal surfaces can be used
to approximate also continuous ones.**

**Definitions**:

- A **face** is a polygon that describes a planar portion of the surface of an
  object.
- The sides of the polygons are called **edges**.
- **Vertices** correspond to the starting and ending points of the edges.
  - Two vertices create an edge
  - Three faces intersect at a given vertex
- If every edge is adjacent to exactly two faces, the object is called as a
  **2-manyfold**,
  - **Non-2-manyfold usually represent objects with holes or lamina-faces. We
    will need special care to render these objects correctly**.

**Each face can be reduced to a set of triangles that share some edges**. A set
of **adjacent triangles is called a mesh**. **Meshes are encoded as a set of
vertices**. The **rendering engine uses such vertices to determine the endpoints
of the triangles that compose the mesh**.

**Several types of mesh encoding** have been defined, however only two of them
are standard in Vulkan: **triangle lists and strips**.

> OpenGL supported also triangle fans, however it is optional in Vulkan.

- **Triangle lists**: encode **each triangle as a set of three different
  coordinates**. They do not reuse any vertex, leading to duplicated vertices.
  To encode $N$ triangles they need $3N$ vertices.
- **Triangle strips**: encode a **set of adjacent triangles that define a
  band-like surface**. The encoding begins by considering the first two
  vertices, then each new vertex is connected to the previous two. To encode $N$
  triangles we need just $N+2$ triangles.

There are however **circumstances where triangle strips cannot be used even if
the topology would seem appropriate: vertices are defined by more than their
position**. This means that is is possible for two vertices to be different even
if they have the same position.

Many primitive objects cannot be encoded using a single triangle strip.
**Indexed primitives is a way to allow us to reduce the memory usage even
further**.

Indexed primitives are defined by **two arrays**:

1. The **vertex array** contains the definitions of the different vertices
2. The triangles are specified in an indirect way using the **index array**, an
   **array of indices of the vertex array**.

To save even more space we can use an **indexed triangle strip**. Vulkan also
provides some optimizations for restarting strips using negative indexes.

### Wireframes

Sometimes it is useful to display only the edges of objects, this is called a
wireframe meshes. The two main types of wireframe meshes: line lists and line
strips. These works just like the triangle equivalent. Wireframe primitives can
also be indexed.

**Vulkan allows us to draw standard objects using only the contour of their
triangles**.

## Pipelines

**In order to transform a set of data representing meshes to an image on screen,
a sequence of operations need to be performed. This sequence is called a
pipeline**.

In vulkan and in CG in general, the process of creating an image on screen
starting from the primitive description is **accomplished through a set of steps
that can be organized as a pipeline. Each step in the pipeline can be either
fixed and defined by the system or programmed by the user using programs called
shaders**.

There are **different types of pipelines**, with different purposes. The latest
vulkan spec defined 4 types of pipelines:

1. Graphic pipeline
2. Ray-traced pipeline
3. Mesh shading pipeline
4. Compute pipeline
