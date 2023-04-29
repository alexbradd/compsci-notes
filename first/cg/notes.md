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
2. Ray traced pipeline
3. Mesh shading pipeline
4. Compute pipeline

**In vulkan, shaders are defined by SPIR-V code blocks**. SPIR stands for
Standard Portable Intermediate Representation and it is a **binary format for
specifying instructions that a GPU can run in a device independent way**. **Each
driver will then compile SPIR-V into device-specific instructions. Shaders are
written in high-level languages such as GLSL and compiled into SPIR-V**.

### Rendering

To obtain realistic images with filled 3D primitives, **light reflection should
be correctly emulated**. Rendering reproduces the effects of light **by defining
the light sources of the virtual environment, and the surface properties of the
objects populating the 3D world**. The light sources are elements of the scene
from which illumination starts. The photons emitted by the light sources bounce
on the objects, and some of them reach the viewpoint (the camera). Rendering
computes the quantity and the color of such photons. **The quantity of light
reflected depends on the input direction, and can bounce in many different
output directions**.

Definitions:

- The **energy** measures the total light emitted by a surface in all the
  directions during a time interval.
- The **power** is the instantaneous light energy (emitted by a surface in all
  the directions in a given time instant).
- The **irradiance** is the fraction of power emitted by a point of a surface
  (in a given time instant). It is measured in $W / m^2$. It will be denoted by
  letter $E$.
- **Radiance** measures the energy emitted in a given time instant from a point
  of a surface in a given direction. It is measured in $W / (m^2 \cdot sr)$
  (where $sr$ are steradians). It will be denoted by letter $L$.

Readings of most light sensors (including the human eyes and cameras) are
proportional to the radiance.

**Rendering determines the radiance received in each point of the projection
plane (i.e each pixel of the screen) according to the direction of the
corresponding projection ray**.

**The surface properties of one object can be encoded in a function called the
Bidirectional Reflectance Distribution Function (BRDF)**. The function **inputs
are the incoming $\omega_i$ and outgoing $\omega_r$ directions**. They are both
unit vectors. The function **returns how much irradiance from the incoming angle
is reflected to an outgoing angle**. It is measured in $sr^{-1}$.

A good BRDF should satisfy **two main properties**:

1. **Reciprocity**: if the ingoing and outgoing directions are swapped, the
   value of the function does not change
2. **Energy conservation**: the BRDF cannot increase the total irradiance that
   leaves a point on a surface

   $$
    \int f_r(\omega_i, \omega_r)\cos \theta_r d\omega_r \leq 1
   $$

The BRDF allows **relating together the irradiance in all the directions for all
the points of the objects composing a scene. This relation is called the
rendering equation**:

$$
  L(x, \omega_r) = L_e (x, \omega_r) +
    \int L(y, \vec{yx})f_r(x, \vec{yx}, \omega_r)G(x,y)V(x,y)dy
$$

**Terms**:

- $L_e$ characterizes **light emission** from a point in some direction
- The **integral** accounts for the **light that hits the considered point $x$
  from all the points $y$ of the surfaces of all the objects and lights in the
  scene**.

  It also includes points of the same objects to allow the computations of
  effects such as self-shadowing/self-reflections.

  - $L$ is the **radiance** emitted toward point $x$
  - $f_r$ is the **BRDF** of the material of the object at point $x$
  - $G$ encodes the **geometric relation** between $x$ and $y$. It considers
    both the relative orientation and the distance of the two points.

    $$
      G(x,y) = \frac{\cos\theta_c \cos\theta_y}{r_{xy}^2}
    $$

  - $V$ considers the **visibility** between point $x$ and $y$. This term is 1
    if the two points can see each other, 0 otherwise. This terms allow for the
    computation of shadows.

$L$ is our unknown in the equation, meaning that **it is an integral equation of
the second kind**.

The equation is **repeated for every wavelength** $\lambda$ of the light:
usually this means that the equation is repeated for the three different RGB
channels.

This rendering equation can be **extended to simulate other effects such as
transparency or other mediums like gasses**.

#### Rendering equation extensions: transparency

The first extension is to consider transmitted lights: this is **done by
defining the BTDF**: Bidirectional Transmittance Distribution Function. **It has
a similar definition to the BRDF, but it is used in the opposite direction**:

$$
  f_t(\theta_i, \phi_i, \theta_r, \phi_r) = f_t(\omega_i, \omega_r)
$$

Since usually the angles for the BRDF and BTDF do not overlap, they are
**included in a single function called BSDF**: Bidirectional Scattering
Distribution Function.

The rendering equation can be updated as such:

$$
  L(x, \omega_r) = L_e (x, \omega_r) +
    \int L(y, \vec{yx})f_r(x, \vec{yx}, \omega_r)G(x,y)V(x,y)dy +
    \int L(y, \vec{yx'})f_t(x', \vec{yx'}, \omega_r)G(x',y)V(x',y)dy
$$

#### Rendering equation extensions: transparency

A more complex function, called **BSSRDF** (Bidirectional surface reflectance
distribution function) must be used. **The function has an extra parameter $x'$
that considers the point on the surface from which lights enters at angle
$\omega_i$**. The rendering equation now **integrates over all the points of an
object to compute the quantity of lights that exits from a give position**.

$$
  L(x, \omega_r) = L_e (x, \omega_r) +
    \iint L(y, \vec{yx'})f_{ss}(x', \vec{yx'}, \omega_r)G(x',y)V(x',y)dx'dy
$$

#### Solving the rendering equations

The rendering equations are **very hard to solve**, and generally require
complex discretization techniques. We will see very **simple approximations** to
the rendering equation that are capable of providing good results with
reasonable complexity. Some of them, are supported in Vulkan with specific types
of pipelines.

Several approximations to BRDF functions have been proposed in the literature:
some of them can provide good results during rendering, even if they do not
satisfy the two previous properties. In the following lessons, we will present
several common BRDF functions and how can they be implemented using Shaders.
Databases that provides measured BRDF exist: see for example the MERL database.

To characterize different approximations to the rendering equation, **light
sources can be divided into direct and indirect**.

- **Direct** sources represent **lights** coming from specific positions and
  directions
- **Indirect** sources consider **all the other types of illumination**, mainly
  caused by **light bounces** and reflections among the surfaces.

With only direct sources, images become very dark and do not seem very
realistic: if a point is not hit by any light, it appears black. Projected
shadows are created by the occlusion of direct light sources. **Indirect
lighting** adds realism, by making elements in directions not directly hit by
sources still visible thanks to light bounces, but it **requires a lot of
computation**, and it is not easy to implement in real time.

In most of the cases, **light contribution for single points and directions is
computed off-line and stored in some image-based structure, which is later used
to approximate indirect lighting in real-time rendering**.

### Scanline rendering

It is the **simplest approximation of the rendering equation**. It **considers
light sources and objects separately**: the scene has a set of objects and a set
of light sources. **No projected shadows or indirect lighting are produced**.

**Lights** are characterized by having **only the emission** term in the
rendering equation (it can have arbitrary position and direction).

Points that define the **vertices** of the triangles belonging to a mesh are
**projected** on screen, finding the corresponding hardware coordinates. All
**pixels belonging to a triangle are then enumerated**. **Each pixel becomes a
point for which the rendering equation is solved**.

**Objects only reflect lights**. They **might emit** some light, but **they
cannot illuminate other objects**. **Inter-reflection between objects is not
considered**, thus the integral becomes a summation over all the light sources.
The **geometric term is generally included in the BRDF**, obtaining:

$$
  L(x, \omega_r) = L_e(x, \omega_r) +
    \sum_l L_e (l, \vec{lx}) f_r (x, \vec{lx}, \omega_r)
$$

**Visibility is considered only with respect to the observer, by means of the
z-buffer** algorithm that will presented in the future.

Since term **$V()$ of the rendering equation is not considered for lights,
scan-line rendering does not generate projected shadows**. **Neither it does
include light emitted by other objects in the scene**, and thus it does not
produce reflection, refraction or indirect illumination. However, **it considers
different types of BDRF functions that can describe the materials composing the
objects in a detailed way**.

#### The "graphics" pipeline

Vulkan supports **scan-line rendering**, with a specific type of pipeline,
called the **"graphics" pipeline**.

Up to **five different types of shaders can be used** to define the functions of
the programmable stages of the pipeline. Only the **initial and final stages are
generally required**. This means that **in most of the cases, only vertex and
fragment shaders are required to generate an image**. If any optional stage is
present, the pipeline ignores such shaders and continues processing.

Stages of the pipeline:

1. **Input assembler**: whenever a draw command is issued, **Vulkan creates the
   vertices by combining all parameters that describe them**. This stage also
   **decides if we are drawing point, lines or triangles, using lists or other
   strip-based approaches**.
2. **Vertex shader**: vertex shaders **perform operations on each vertex**:

   - Transform local coordinates to clipping coordinates
   - Compute colors and other values associated to vertices

   These values can be used later the pipeline.

3. **Tessellation shader**: tessellation is used to **increase the resolution of
   an object**: for example a sphere can be approximated by few triangles when
   distant from the viewer, or with a very high number of subdivisions when seen
   from a close distance.
4. **Geometry shader**: it can **remove or add primitives to the stream**,
   starting from the previously generated elements. In principle, it could
   perform the same tasks as Tessellation stages. However, due to its
   generality, it would result in more complexity.
5. **Rasterization**: it **determines the fragments in the frame-buffer occupied
   by each primitives**. They are called fragments and not pixels, since a
   single pixel on screen can be computed by merging several fragments to
   increase the quality of the final image. In these stages, transformation of
   clipping coordinates into normalized screen coordinates is also performed.
   **Fragments are usually generated per line**, left to right, with respect to
   the corresponding triangle, from here comes the name of the method.
6. **Fragment shader**: determines the final color of each fragment. In this
   stage physically based models or other artistic techniques are used to
   produce either realistic or effective images.
7. Finally, the **computed colors might either replace or be merged with the
   ones already present in the same position**. This can be used to implement
   **transparency, or other blending effects**.

We will not cover tessellation and geometry shaders.

#### Ray casting

Ray casting is an **extension of scan-line rendering** that **computes the
visibility function for all the (triangle point, scene light) tuples in the
scene**.

$$
  L(x, \omega_r) = L_e(x, \omega_r) +
    \sum_l L_e (l, \vec{lx}) f_r (x, \vec{lx}, \omega_r) V(x,l)
$$

Ray casting **allows including projected shadows**. The **visibility function is
computed by casting a ray that connects the considered points with each light
source**: if the ray intersects an object, the light is occluded and its effect
is not considered in the rendering equation.

**One of the typical techniques to test if a light is occluded in real-time is
using shadow maps**: an image rendered from the position of the light source,
where each pixel represent the distance of the point from the light.

Ray casting is **generally implemented using the graphics pipeline, by executing
several passes to compute the shadow maps**, and to use them in determining the
final colors.

### Ray tracing

Ray tracing **considers for each pixel also the light emitted by other objects
in two specific directions: the mirror reflection and the refraction** (for
transparent objects).

For **reflection**, this **direction corresponds to the mirror direction with
respect to the normal vector of the surface in the considered point**. This
allows the reproduction of realistic perfect reflections. In particular, for
each point $x$, the algorithm looks for the objects in direction $\vec{rx}$, the
one that has the same outgoing angle with respect to the normal vector as the
incoming one.

For **refraction**, the **physical properties of objects are emulated by
considering the index of refraction of materials to determine the angle at which
the refraction ray will be cast**. In this case, **for each point $x$ the
algorithm searches for the objects in direction $\vec{tx}$, calculating $x’$
using the different refraction indices of the solids at the two sides of the
surface**.

The algorithm **relies on a ray casting procedure that computes the colors seen
from a given $(x, \omega)$ tuple**. The procedure **searches for the closest
object to point $y$ in the given direction $\omega$ and applies the approximated
rendering equation to compute $L(y, \omega)$**.

The algorithm **starts by considering each point on the projection plane** (i.e.
each pixel of the generated image) **in the direction of the projection ray**.
It then executes the **ray-casting** procedure from it. For **handling the
reflection and refraction part**, the **procedure is called recursively with
different points and direction rays**. The **recursion is repeated up to a given
number of bounces, called ray depth**.

Vulkan and DirectX, both have a specific pipeline to support ray tracing in real
time (provided that suitable GPUs are available).

#### The ray tracing pipeline

The ray tracing pipeline **creates images from pixels on screen: it is not
driven by triangles and their corresponding vertices**. **For each fragment, a
ray is cast into the scene and it is intersected with all the triangles of all
the meshes in the 3D environment**. Only the intersection closer to the viewer
is considered. **In order to compute its color, extra rays can be traced to
accurately reproduce reflections and refraction** (or transparencies).

**Determining the intersection with all the triangles in the scene is not a
simple task**: without special care, it can have $\mathcal{O}(n^2)$ complexity
in the number of triangles. In order to cope with this complexity, **special
acceleration structures must be used**.

The ray tracing pipeline requires **5 shaders**:

1. `RayGen`: executed **for each fragment** of the image, **it must determine
   the starting point and the direction of the corresponding ray in the scene**
2. `Intersection`: implements **ray-triangle intersection**
3. `Closest hit`: called on the point that is closer to the viewer, **computes
   its color**. For achieving this, **it can recursively cast other rays**
4. `Any hit`: **filters out intersections that should not be considered**
5. `Miss`: **called if the ray does not hit any object**

**The fixed part of the pipeline controls the acceleration structure traversal,
and the determination of the closest hit**.

The **pseudocode** of a ray tracing rendering algorithm can be the following:

```txt
for each pixel x on screen
  r = cast_ray_from(x)
  compute_color(r)

function compute_color(r)
  q = point_of_object_closest_to(r)
  color = 0
  for each light l in scene
    if !occluded(l)
      c += l.contribution_to(q)
  c += calculate_reflection(r) # recursive call
  c += calculate_refraction(r) # recursive call
```

The **number of traced rays potentially doubles at every step**. This can
significantly increase the rendering times. Moreover, it requires computation of
the closest intersection using the acceleration structure instead of the
Z-buffer (which is more computation intensive).

**Ray tracing allows including mirror reflection and transparency with
refraction**: this can be used to realistically reproduce glass, fluid, shiny
metals and many other objects. However, ray tracing **is not able to simulate
indirect lighting or consider glossy reflections**, limiting the level of
achievable realism.

### Radiosity

Radiosity proposes a **different simplification to the rendering equation**. In
particular it **considers only materials that have a constant BRDF**. The
unknowns of the rendering equations are thus reduced to one variable per point
of object since reflections do not depend on the direction from which they are
seen. This **unknown** is called the **radiosity of the object**.

$$
\begin{gathered}
  f_r(x,\omega_i, \omega_r) = \rho_x \\
  L(x) = L_e(x) + \rho_x \int L(y)G(x,y)V(x,y)dy
\end{gathered}
$$

The **surfaces of objects are then split into patches, with one unknown per
patch**. **Light sources are implemented as patches that emit radiosity**. The
**rendering equation becomes a (large) system of linear equations that can be
solved with an iterative technique**. We can write it as a matrix expression:

$$
\begin{aligned}
  L(x) &= L_e(x) + \rho_x \int L(y)G(x,y)V(x,y)dy \quad\text{becomes}\\
  L(x_i) &= L_e(x_i) + \rho_{x_i} \sum_{y_j} L(y_j)G(x_i,y_j)V(x_i,y_j) \\
    &= L_e(x_i) + \sum_{y_j} L(y_j)R(x_i, y_j) \\
  L = L_e + R \times L
\end{aligned}
$$

The **solutions of the systems are then interpolated** to produce the view of
the scene.

**Pseudocode** for the algorithm can be:

```txt
dicretize_scene()   # very intensive
R.compute()         # very intensive
L = solve_system(R) # very intensive
render_scene()      # can be done with either scan-line or ray tracing
interpolate(L)
```

**Once the most intensive steps are done, the scene can be re-rendered quickly
from any point of view**.

Radiosity is **able to capture indirect illumination effects**. **Shadows are
usually very poorly approximated** due to the size of the patches. **Mirror
reflections and refractions cannot be considered directly**, since they depend
on the direction from which the object is seen.

### Montecarlo techniques

**Photorealistic results can only be achieved by approximating the solution of
the complete rendering equation**. Due to its complexity, **Montecarlo
techniques are usually employed**: the **integral is computed by averaging
several random points and directions chosen from the equation**.

Many alternative approaches are possible: each advanced rendering engine
exploits one of them.

1. **Instead of sending a single ray in the mirror direction, a sampling of the
   most probable output directions is considered**. A ray is thus traced for
   each selected direction, and the radiance is computed using the BRDF of the
   considered material.
2. **Photon mapping emulates the movements of photons in the scene**,
   considering bounces, focalizations and other advanced phenomenon such as
   caustics.

**Due to the randomness** that drives the techniques, Montecarlo based rendering
algorithms tend to **produce noisy images**. This effect **can only be reduced
by increasing the number of rays** and consequently the rendering time.

### Mesh shader pipeline

**Mesh shaders compute indexed triangle lists, returned as a set of vertices and
groups of three indices for each triangle**. Vertices are computed in normalized
screen coordinates, to simplify rasterization. **The number of vertices and
triangles that a mesh shader can generate is limited**. For this reason each
**object is divided in so called meshlets**: small patches of a mesh.

The optional `Task` shader subdivides a larger mesh into smaller meshlets and
controls the mesh shader for the creation of all the required patches.

**The generated triangles lists is then fed into the rasterization pipeline**.

### Compute pipeline

The compute pipeline is **not for rendering images, but for performing GPGPU
tasks**. The application provides a **single shader, the compute shader, that
performs the desired computations**.

Data is copied into buffers in GPU memory. **Compute shaders executions are
identified by a (up to) tridimensional index**. **Using this index, the shader
can refer to the data to find the partition on which it can work**.

If you want more, follow the dedicated course (if available).

## GLSL

Most of the BRDF functions, and light emission models, will be implemented in
shaders written with the GLSL language. We have already seen how we can compile
a shader from source to its SPIR-V intermediate format.

GLSL is a C-like language, and it is very similar to C, C++, C#, JAVA,
JavaScript and others.

Shaders follow the classical convention of having global variables and functions
in the main scope of the file. **The entry point of the shader can be defined in
the code that calls it. However, it is generally the function `main()`**.

As examples, here are vertex and fragment shaders that compute the Mandelbrot
fractal.

```glsl
// ==== Vertex shader ====
#version 450 // minimum version supported by vulkan, it is required

layout(set = 0, binding = 0) uniform
UniformBufferObject {
  mat4 worldMat;
  mat4 vpMat;
} ubo;

layout(location = 0) in vec3 inPosition;
layout(location = 0) out float real;
layout(location = 1) out float img;

// The main procedure
void main() {
  gl_Position = ubo.vpMat * ubo.worldMat * vec4(inPosition, 1.0);
  real = inPosition.x * 2.5;
  img = inPosition.y * 2.5;
}

// ==== Fragment shader ====
#version 450

// Variables can be preceded with different qualifiers. Most of them are
// required to interface with the pipeline
layout(location = 0) in float real;
layout(location = 1) in float img;

layout(location = 0) out vec4 outColor;

layout(set = 0, binding = 1) uniform
  GlobalUniformBufferObject {
  float time;
} gubo;

void main() {
  // Variables are typed and follow the C naming convention
  // Variables are local to the block they are defined in
  float m_real = 0.0f,
        m_img = 0.0f,
        temp;
  int i;

  // Control structures work as in C
  for(i = 0; i < 16; i++) {
    if(m_real * m_real + m_img * m_img > 4.0) {
      break;
    }
    temp = m_real * m_real - m_img * m_img + real;
    m_img = 2.0 * m_real * m_img + img;
    m_real = temp;
  }
  outColor =
    vec4((float(i % 5) + sin(gubo.time*6.28)) / 5.0, float(i % 10) / 10.0, float(i) / 15.0, 1.0);
}
```

GLSL supports a number of types, including scalars (the usual), vectors and
matrices (type name is identical to GLM, they by default are floats).

**Vectors can be accessed using the "dot" syntax with aliases** (e.g.
`x`/`r`/`s`, `y`/`g`/`t`, `z`/`b`/`p`, `w`/`a`/`q` based on the vector meaning).
**More than one letter can be used to refer to more elements and shuffle them
around** (e.g. `light.zxy` or `light.rb`).

Matrix types are the most commonly used (`2x2`, `3x3` and `4x4`). **We can
address the column and elements of the matrices using C-like array syntax**.

Matrix and vector types can be constructed by using a constructor with the name
of the type, with arguments the elements of the vector/matrix. Larger vectors
can be composed by adding elements to shorter ones (e.g. `vec4(my_vec3, 1.0)`).
The same "constructor" syntax can be used for explicit casting.

Algebraic operations, including between vectors and matrices, is done using the
conventional operators. The other common C operators are also defined.

Functions are defined using the C syntax, invocation is the same. Many
mathematical, trig and geometric functions are already defined.

**Please note that control flow statements behave differently than on a CPU. The
SIMD architecture always processes many elements at the same time and has some
nasty implications**:

- **Both the if and else branches are always executed**.
- **In variable length loops, all executions are conditioned by the longest one
  in the batch being run concurrently**.

This is why **it is always a good idea to try to avoid loops and conditional
statements as much as possible**.

**Communication between the shaders and the pipeline occurs through global
variables**:

- **`in` and `out` variables** are used to** interface with the programmable**
  or configurable part of the pipeline
- Communication with the **fixed part of the pipeline occurs using predefined
  global variables** (e.g. in a vertex shader, `gl_Position` is a `vec4`
  variable that must be filled with the clipping coordinates of the
  corresponding vertex)
- **Communication between shader and the application occurs using special types
  of external variables**
  - The most common on are the **Uniform variable blocks**
  - Each **block is similar to a C struct**

## Final fixed part of the scan-line pipeline

### Clipping

Clipping is **usually performed after the projection transform but before
normalization**. For this reason, the space in which it is performed is called
**clipping coordinates**.

If we use homogeneous coordinates, **we can identify a plane with a four
component vector** $n = (n_x, n_y, n_z, d)$. In this way, **the plane equation
becomes a scalar product between the homogeneous coordinates of the point and
the vector representing the plane**.

$$
  n \cdot (x, y, z, 1)^T = n_x x + n_y y + n_z z + d = 0
$$

**A point is in one of the half-spaces defined by the plane depending on the
sign of the scalar product**.

**Since the clipping frustum is a convex solid, we can represent its volume by
using intersection of the half-spaces** that delimit its six faces: **a point is
inside the frustum if all 6 scalar products are positive**.

When considering **triangles**, this problem becomes **more difficult**. The
**distance** from a plane with normal $n_v$ is computed by using **the scalar
product of the coordinates of the vertices with the normal vector**. We have a
**trivial reject/accept for the side if the three distances are all
negative/positive**. **In the case of a negative, the algorithm stops** (since
it is outside the frustum), while **for accepts it moves on to checking the
other sides**.

If only **two points are outside**, then **two intersections between the
triangle and plane are computed using interpolation**. The distance from from
the plane is used as interpolation coefficients.

If just **one point is outside**, **two intersections** on the segments that
connect the point **are calculated**. In this case **two triangles are
produced**.

The algorithm continues **for each side until all triangles have been clipped or
rejected**. **If new triangles have been generated, they are considered
separately**.

The algorithm is simple, but **it can produce a large number of triangles**
since **triangles can double at every iteration**. This has also **implications
on the data structure required to store the triangles**, since it must be able
to accommodate a variable number of figures. Moreover, **computing the
intersection is usually very complex, since it must take into account all the
parameters assigned to vertices** which can be a lot (e.g. normal vectors,
colors and UV coordinates).

### Back-face culling

Back-face culling can **exclude the faces that belong to the backside of a
mesh** by **checking whether the triangle vertices are ordered clockwise or
counterclockwise with respect to the view**. The **check can be performed either
before the projection of the triangle or using the normalized screen
coordinates** (Vulkan implements back-face culling in normalized screen
coordinates).

Let us suppose that **all triangles of a mesh are encoded using a consistent
orientation**, for example clockwise. **Once projected on screen, front faces
will still be ordered clockwise**, while back faces will be ordered in the
opposite direction. The **orientation of the vertices of a triangle in
normalized screen coordinates can be computed with a simple cross-product**: if
the result vector is oriented toward the viewer (positive z component), then the
vertices are ordered clockwise. Since only the sign of the z component is
required, the test can be performed in a very efficient way.

Back-face culling **can improve the performances of an application, however
there are some potential issues** that can arise:

1. There are **transforms that change the ordering of the vertices** (i.e.
   mirroring)
2. Not all software that produces 3D assets use the same **convention for front
   faces**
   - **This and (1) can be solved by allowing a way to specify the order**
     (clockwise or counter-clockwise)
3. If a **world matrix includes a scaling component with an odd number of
   negative coefficients** (either one or all three), the **acceptance test must
   be inverted**
4. Back-face culling **cannot be always applied**, for example in non 2-manyfold
   objects
5. **Transparent objects** needs their back faces to be drawn

### Depth testing (z-buffer)

The simplest method to order the visibility of objects is technique called
**"the painter's algorithm": primitives are drawn in reverse order with respect
to the distance from the projection plane**. In this way, objects closer to the
view cover the ones further apart. There are **cases in which a correct order
cannot be determined** and algorithm cannot be applied.

The **z-buffer** method **orders the primitives at the pixel level**. It
**requires a special memory area that stores additional information for every
pixel** on the screen, which is called the **z-buffer** or the depth-buffer.

The algorithm **draws all the primitives** in the scene and **tests whether to
draw their corresponding pixels on screen**. **For each pixel, both the color
and the distance from the observer are computed**. The **z-buffer stores the
distance from the observer** (i.e. the normalized screen z coordinate) for each
pixel on the screen. **When a new pixel is written, its distance from the
observer is compared against the value stored in the z-buffer**: the **new pixel
is written** on screen **if its distance is less than the one in the z-buffer**;
the value in the **z-buffer is also updated** with the new distance. If instead
the **distance** of the new pixel is **greater than the value stored in the
z-buffer**, the new **pixel is discarded** (since it corresponds to an object
behind the one already shown).

The z-buffering technique is very **simple, but it requires an extra memory area
that can store the distance information for all the pixels**: **in Vulkan**,
this memory area **must be created by the programmer**, making the use of
z-buffer more complex than in other environments. Moreover, **it requires the
generation of all the pixels of all the primitives in the scene, even if they
are completely covered by other objects**.

**The worst issue is the numerical precision: the largest part of the $[0,1]$
range of $z_s$ is used for the points that are very close to the projection
plane**. This means that **we need sufficient precision to store the depth
information for distances that are further away**. Otherwise a problem known as
"Z Fighting" may occur: when two almost co-planar figures are rendered, the
final color is determined by the round-off of the two distances.

Since $z_s$ **is normalized with respect to the position of the near and far
planes**, these two parameters **cannot be set arbitrarily small and large**:
they should always be appropriate for the considered scene.

### Stencil buffer

Stencil buffer is a **technique similar to z-buffer**, usually **adopted to
prevent an application from drawing in some region of the screen**. Like
z-buffering, it is **implemented by storing additional information for every
pixel on the screen in a special memory area called the stencil buffer**.

The stencil buffer **associates an integer to each pixel**, which is usually
encoded at the bit level. During rendering, stencil buffer data can be used to
perform specific tasks on the corresponding pixel.

## Vulkan applications

A large number of steps are essential to exploit all the Vulkan features in an
application. However, in most of the cases the user will relay on the same
(solid) start-up sequence.

A typical vulkan has the following skeleton:

```cpp
void run() {
  initWindow();
  initVulkan();
  initApp();
  mainLoop();
  cleanup();
}
```

The **screen area where the host operating system allows Vulkan to draw images
is called the presentation surface**. In order to work properly, a Vulkan
application should acquire a presentation surface from the o.s. This is system
dependent. In a desktop system, the presentation surface will always be
contained inside a window.

### Opening a window

The window is created using **GLFW** in the following way:

```cpp
void initWindow() {
  glfwInit();

  glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API); // required since we are not
                                                // using OpenGL
  window = glfwCreateWindow(WIDTH, HEIGHT, "Vulkan", nullptr, nullptr);
}
```

### Vulkan's architecture

The Vulkan architecture is a **tree-like architecture**:

1. At the top there is the **vulkan application**
2. An **application** can have different **instances**; instances allow
   **different libraries to use the GPU independently** from each other
3. **Each instance** can use one or more **physical devices**; physical devices
   are essentially the **GPUs** in the system
4. **Each physical device** can have **different configurations** that can
   coexist; **logical devices** represent such a configuration
5. To maximize parallelization, **all actions** performed by Vulkan are **placed
   into** **queues**; the user can request multiple queues
6. Vulkan **operations are stored in command buffers**, which are transferred to
   GPU memory; each queue may handle several command buffers

Vulkan is **subdivided into different components**:

1. A **fixed component** called **"vulkan loader"**
2. A set of **GPU dependant drivers called "Installable Client Devices" (ICD)**
3. **Extension layers**: they expose OS/device-specific functions.
   - The `vkEnumerateInstanceExtensionProperties` function enumerates available
     extensions

### Instance creation

In order to create an instance, we need to **specify the list of requested
extensions, the name and other features of the application**.

```cpp
VkInstance instance;

VkApplicationInfo appInfo{};
appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
appInfo.pApplicationName = "Assignment 12";
appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
appInfo.pEngineName = "No Engine";
appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0);
appInfo.apiVersion = VK_API_VERSION_1_0;

VkInstanceCreateInfo createInfo{};
createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
createInfo.pApplicationInfo = &appInfo;
createInfo.enabledExtensionCount = glfwExtensionCount;
createInfo.ppEnabledExtensionNames = glfwExtensions;
createInfo.enabledLayerCount = 0;

VkResult result = vkCreateInstance(&createInfo, nullptr, &instance);

if (result != VK_SUCCESS) {
  throw std::runtime_error("failed to create instance!");
}
```

GLFW has the `glfwGetRequiredInstanceExtensions(uint32_t* count)` helper that
returns the required extensions (and number) to allow the application to work in
the considered operating system.

The minimal main loop just waits for the user to close the window, infinitely
polling events using the relative GLFW helpers:

```cpp
void mainLoop() {
  while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();
  }
  cleanup();
}
```

**Instances should be released on exit using the appropriate destructors**.
**GLFW also requires de-initialization** of the window and state.

```cpp
void cleanup() {
  vkDestroyInstance(instance, nullptr);
  glfwDestroyWindow(window);
  glfwTerminate();
}
```

### The presentation surface

The creating a presentation surface requires both a window and a Vulkan
instance. **GLFW can create the presentation** surface with
`glfwCreateWindowSurface(instance, window, nullptr, &surface)` and return a
handle to the surface in the `VkSurfaceKHR*` parameter.

The presentation surface **also needs deallocation on application exit** using
`vkDestroySurfaceKHR(instance, surface, nullptr)`.

### Physical devices

Since the system may have multiple GPUs, we need a **way to select the most
appropriate one**. We do this by:

1. **Enumerating** the devices using:

   ```cpp
   uint32_t count;
   result = vkEnumeratePhysicalDevices(instance, &count, nullptr);
   if (result != VK_SUCCESS || deviceCount <= 0) {
     trow std::runtime_error("failed to find vulkan-capable GPUs");
   }
   std::vector<VkPhysicalDevice> device(deviceCount);
   result = vkEnumeratePhysicalDevices(instance, &count, devices.data());
   if (result != VK_SUCCESS) {
     trow std::runtime_error("could not enumerated devices");
   }
   // ...
   ```

2. **Checking their features**: each device is characterized by:

   - Properties
     - Queried with `vkGetPhyiscalDeviceProperties()`
     - Structure: `VkPhysicalDeviceProperties`
   - Features: e.g. support for specific shaders, data types etc...
     - Queried with `vkGetPhyiscalDeviceFeatures()`
     - Structure: `VkPhysicalDeviceFeatures`
   - Memory types: shared, GPU-specific etc...
     - Queried with `vkGetPhyiscalDeviceMemoryProperties().memoryTypes`
     - Structure: `VkMemoryType`
   - Memory heaps: available memory
     - Queried with `vkGetPhyiscalDeviceMemoryProperties().memoryHeaps`
     - Structure: `VkMemoryHeap`
   - Queue families: which type of operations it can perform

3. **Ranking** them according to our requirements
4. **Selecting** the one with the **highest rank**

### Logical devices and queues

As we have seen logical devices are created from a physical device. Each
**logical device one contains one or more queues of different types**. The
selection of the physical device might also be influenced by the queues its
logical devices can use.

**Queues are grouped into families**, each one supporting different types of
executable operations. Families supported by a physical device can be enumerated
with `vkGetPhysicalDeviceQueueFamilyProperties()` into an array of
`VkQueueFamilyProperties` structures.

When the physical device has been selected, we can use it to create a logical
device. In the selection process **we must check if there exist queues
supporting graphics and presentation**, exploiting the `has_value()` method of
the `std::optional` objects. **Logical devices are created together with their
queues** in using the `vkCreateDevice()` command, starting from a physical
device. On success, the `VkDevice` structure containing the device handle passed
to the command is filled. Queue handles must be retrieved using the
`vkGetDeviceQueue()` command. **At application exit, logical devices must be
released**.

### Command buffers

Once queues has been retrieved, command buffers using them can be created.
**Since the use of several command buffers is common, they are allocated from
larger groups called command pools. Each command pool is strictly connected to
the Queue families it uses**.

Command pools are created with the `vkCreateCommandPool()` function. The only
parameter that needs to be defined in the creation structure is the queue family
on which its commands will be executed using the `queueFamilyIndex` field. On
success, the handle to the command pool fills the `VkCommandPool` argument.
Command Pools must be released when no longer necessary with the
`vkDestroyCommandPool()` function.

**Command buffers are created from the pools** with the
`vkAllocateCommandBuffers()` function, and their handle is returned in a
`VkCommandBuffer` object. The corresponding pool handle is passed in the
`commandPool` field of the creation structure. **Two types of command buffers
are available: primary and secondary**. The **purpose is to allow the creation
of subroutines that can be called from different command buffers**. **Several
command buffers can be created in the same call**: their number is specified in
the `commandBufferCount` field (if more than one buffer is required, the return
value must be an array of sufficient size). **Command buffers are automatically
destroyed when the corresponding pool is released**, so no explicit action is
required.

### Screen synchronization

The CPU, the GPU and the screen run at different and independent speeds.
**Monitors and displays compose the image by updating pixels in a predefined
order (usually, scanning horizontally left to right, and top to bottom). Tearing
happens if the graphic adapter reads into video memory when the program has not
finished yet composing the image.**

Every **graphic adapter sends a `Vsync` interrupt to the processor whenever it
finishes tracing the screen**. The application can intercept this interrupt and
start updating the frame.

Using only one buffer obviously would lead to a lot of wasted time and tearing,
so multiple buffers are used.

#### Double and triple buffering

With double buffering, the video memory has **two frame buffers**: the front
buffer and the back buffer. **While the video adapter is showing the content of
one buffer, the application can compose the image in the other**.

In the beginning the **application works on the back buffer**, while the **video
adapter is showing the other one** (the front buffer). As soon as the new frame
has been composed, the **application waits for `Vsync` and swaps the two
buffers** and starts composing a new frame while the monitor is showing the
finished one.

Double buffering has a **major drawback**: the **application must stop composing
the image as soon as a frame is completed and wait for `Vsync` to continue**.
This **limits the frame rate to that of the monitor** and creates locks in the
application, reducing the utilization of both CPU and GPU.

**Triple buffering solves this issue by allowing the application to draw
independently from the presentation**. Initially, the **application works on one
frame buffer, while the system is displaying another. As soon as the application
has finished composing the screen, it starts working on the next frame in the
unused buffer**. At the next `Vsync`, the last fully composed frame is shown.
**While waiting for the `vSync`, the application can switch as many times as
needed between the two back buffers**. If a frame is completed before the
`vSync` is received, the previous one is skipped.

**Frame skipping allows having frame rates higher than that of the display**.
Swapping at the `Vsync`, allows for smooth animations and prevents tearing. The
**drawbacks** of triple buffering are the **memory requirements** and the
possibility of the **CPU and GPU wasting a lot of processing power on discarded
frames**.

### Vulkan swapchain

In Vulkan, **screen synchronization is handled with a generic circular queue,
called the swapchain**. It can handle Single, double, triple and potentially
even longer presentation queues.

To allow Vulkan to be as independent as possible from the context, **swapchain
support must be enabled** by adding the `VK_KHR_SWAPCHAIN_EXTENSION_NAME` device
extension to the logical device creation procedure.

**Each swapchain is characterized by**:

- A set of **capabilities**: e.g. the size of the framebuffer, and the minimum
  and maximum number of buffers supported etc...
- Several **supported formats**: several alternative formats with different
  color spaces and resolution exist; each graphic adapter can support a variety
  of them (i.e. 8bpc, 10bpc, 16bpc)
- Several **presentation modes**: the equivalent of synchronization algorithms,
  four main presentation modes are supported (single, double and triple buffer)

When no longer needed, **swapchains can be released with the
`vkDestroySwapchainKHR()` command**.

**Each buffer of the swapchain, is considered by Vulkan as a generic image which
must be retrieved after creation**. Images are identified by `VkImage` objects,
and the ones corresponding to the swapchain are retrieved with the
`vkGetSwapchainImagesKHR` command. **Image Views are the way in which Vulkan
associates to each image the description on how it can be used and accessed**.

## Light modes

In both scan-line rendering and ray-casting the scene is composed by a finite
set of light sources. The contributions of all lights are added together to
compute the final color of the pixel.

Initially, we will ignore the possibility of objects to emit light, further
simplifying the equation:

$$
L(x, \omega_r) = \sum_l L_e(l, \vec{lx})f_r(x, \vec{lx}, \omega_r)
$$

**Each term in the sum is the product of the light model**, that computes the
quantity and direction of the considered light source, **and the BRDF** which
accounts how the surface reflects the light.

A **light model** describes **how light is emitted in different directions**. It
takes as **input the position of a point $x$ of an object**. It **returns two
elements**: a vector that represents the **direction of the light** and **a
color** which accounts for the intensity of light received by point $x$ for
every wavelength.

The direction can be specified with a vector $\vec{lx} = (dx, dy, dz)$: as a
convention, the **sign of the direction is chosen to make the ray point towards
the light source**. Moreover, **the direction is also a unitary vector**. A
**vector** $L(l, l_x = (l_R, l_G, l_B)$ of RGB components defines the **light
intensity**. The components **do not necessarily need to be in the $[0; 1]$
range**: larger values can model stronger light sources. They only **need to be
non-negative**.

As said previously, the rendering equation must be solved for every color
frequency considered. **Since the light color $L(l, l_x)$ is encoded as a
vector, the BRDF function $f_r(x, l_x, \omega_r)$ must return a color vector
too**.

### Direct light

Direct lights are used to **model distant sources such sunlight**. They
uniformly influence the entire scene.

Due to the distance of the source, **rays are parallel to each other in all
positions of space and constant in both color and intensity**. The **direction**
can be specified with a **constant vector** $\mathbf{d}$ that is **independent
of the position of the object**. **Light color** is also specified by a
**constant vector** $\mathbf{l}$. This reduces the rendering equation to:

$$
L(x, \omega_r) = \mathbf{l} * f_r(d, \mathbf{d}, \omega_r)
$$

Where $*$ is the element-wise product.

### Point light

Point lights are **sources that emit light from fixed points in space and do not
have a direction**. They are used to model sources that emit light in all
directions, starting from a specific position in the scene. **They are
characterized by the position** $\mathbf{p}$ **and color $\mathbf{l}$**.

The **direction** can be written as:

$$
  \vec{lx} = \frac{\mathbf{p} - \mathbf{x}}{|\mathbf{p} - \mathbf{x}|}
$$

Point lights also have a **decay factor**, which can be constant inverse-linear
or inverse-squared.

$$
  L(l, \vec{lx}) = \left(\frac{g}{|\mathbf{p} - \mathbf{x}|}\right)^\beta \mathbf{l}
$$

Where **$g$ is the distance at which the intensity decay is exactly 1**. As a
consequence, **intensity will be higher than $l$ for distances shorter than $g$,
and it will be dimmer for longer distances**.

The rendering equation becomes:

$$
  L(x, \omega_r) =
    \mathbf{l}\left(\frac{g}{|\mathbf{p} - \mathbf{x}|}\right)^\beta \mathbf{l} *
    f_r(x, \frac{\mathbf{p} - \mathbf{x}}{|\mathbf{p} - \mathbf{x}|}, \omega_r)
$$

### Spot lights

Spot lights are special **projectors that are used to illuminate specific
objects or locations**. They are **conic sources** characterized by::

- A direction $d$
- A position $p$.
- $\alpha_{in}$
- $\alpha_{out}$

The **two angles divide the illuminated area into three zones**: **constant**
(inside $\alpha_{in}$), **decay** (between the two angles) and **absent**
(outside $\alpha_{out}$).

For implementing spot lights, usually **the cosine of the half-angles of the
inner and outer cones $c_{in}$ and $c_{out}$ are used**. The cosine of the angle
between the light direction vector $\vec{lx}$ and the direction of the light $d$
**can be computed by taking the dot product between the two**. The **cone
dimming effect** is computed as:

$$
  0 \leq \mathit{clamp}(\frac{\cos\alpha - c_{out}}{c_{in} - c_{out}}) \leq 1
$$

Spot lights are **implemented by extending other light sources with the dimming
term** just introduced. In particular, they inherit the light direction
$\vec{lx}_0$ from the model they derive from, and modulate the color
$L_0(l, \vec{lx})$ with the dimming term.

$$
  L(l, \vec{lx}) = L_0(l, \vec{lx})\mathit{clamp}(\frac{\frac{\mathbf{p} -
  \mathbf{x}}{|\mathbf{p} - \mathbf{x}|}\mathbf{d} - c_out}{c_{in} - c_{out}})
$$

The **most popular implementation extends the point light**. Light direction is
computed as for the point light. From now on, when considering spot lights we
will assume this implementation.

### Special light modes

#### Cosine light

When the **inner cone reduces to zero, and the outer cone is maximized**, the
dimming **simplifies** to:

$$
  \mathit{clamp}(\frac{\mathbf{p}-\amthbf{x}}{|\mathbf{p}-\mathbf{x}|}\mathbf{d})
$$

This special light model is sometimes called the "cosine" light model. Although
being very simple, it produces interesting diffuse lighting effects.

#### Area light

Most realistic light sources do not have a point origin, but a **surface of
origin**. Area lights aim at capturing the shape of lights. Due the fact that
the shape must be considered, **single sources can no longer be considered and a
full integral must be used**, even in scanline rendering.

**Current implementations of area lights are based on specific approximation of
the integral and cannot be decoupled from the BRDF of the surfaces**.

## BRDF models

The BRDF used for scan line rendering **does not fulfill the energy conservation
property in most cases**. Generally, it is expressed as the sum of two terms:

1. The **diffuse reflection**: the main **color** of the object
2. The **specular reflection**: models the **reflection** of incoming light at a
   particular angle (specular direction), which depends on the direction from
   which the object is seen ($\omega_r$)

In scan-line rendering, the **values of the BRDF for each color and component
are in the $[0,1]$ range**. Due to lights the **final result can be larger than
1**. The most **common solution is to clamp the values** in the correct range.
This method creates **effects similar to over-exposition**. Other techniques,
called **HDR** techniques, **use more advanced computations that can work with
values outside the $[0,1]$ range and map the final color into the desired
range**. HDR requires more memory and computation power.

### Diffuse reflection models

#### Lambert

The simplest BRDF has **only a constant diffuse term**. This BRDF is used in
Radiosity. This constant BRDF causes a shading phenomenon know as Lambert
reflection.

According to **Lambert's reflection law**, **each point of an object hit by a
ray of light reflects it with uniform probability in all the directions**. This
implies that **the reflection is independent of the viewing angle and
corresponds to a constant value** $f_r(x, \omega_i, \omega_r) = \rho_x$.

The **quantity of light received by an object depends on the angle between the
ray of light and reflecting surface**. Let us call:

- $n_x$ the unitary normal vector to the surface
- $d$ the direction of the ray of light
- $\alpha$ the angle between the two vectors

The incidence of incoming light is maximized when $\alpha = 0^\circ$, and zero
when $\alpha \geq 90^\circ$. Lambert proved that **the amount of light reflected
is proportional to** $\cos\alpha$, which can be calculated as the dot product
between $d$ and $n_x$.

Let us call $m_D$ a **vector that expresses the capability of a material to
reflect light of each of the primary colors**. We can express the **BRDF** for
Lambertian reflection **for scan-line rendering with the following expression**:

$$
f_r(x, \vec{lx}, \omega_r) = m_D\max(\vec{lx}\cdot n_x, 0)
$$

#### Oren-Nayar model

Some materials are characterized by a **phenomenon called retro-reflection**:
they tend to **reflect light not only in the reflection direction but also back
in the direction of the source**. They have **very rough surfaces** and cannot
be accurately simulated with the Lambertian model. This model has been created
to more appropriately model such materials. **In most cases, these materials do
not show specular reflections**.

It uses **three vectors**:

1. The direction of the **light** $d$
2. The **normal** vector $n$
3. The direction of the **viewer** $\omega_r$

These vectors form **three angles**:

1. $\theta_i$ between $d$ and $n$
2. $\theta_r$ between $\omega_r$ and $n$
3. $\gamma$ between the projections of $\omega_r$ and $d$ on the plane
   perpendicular to $n$; we call these two projections $v_r$ and $v_i$
   respectively

The model has **two parameters**:

1. $m_D$: the main diffuse color
2. $\sigma\in [0;\pi/2]$: the roughness of the material

The **formulas** are quite complex and are **on slides** `L15.53` (`L15.54` for
the simplified version using some precomputed textures).

### Specular reflection models

A **perfect mirror surface reflects light only in a single direction** on the
same plane as both the light and the normal, but with the opposite angle. This
means that a **light source would be visible only along this angle** and
invisible in any other direction.

If a **surface is rough**, the **incoming light will also be reflected at angles
near the mirror one**. For this reason, the reflected ray **could be visible at
reduced intensity in an area** near the mirror direction.

**Specular** reflection is the **chance that the reflection occurs in the
considered viewing direction** $\omega_r$.

As for the diffuse case, the specular component is characterized by a **color**
$m_S$ that defines the **color of the light reflected**. For most materials,
this light is white; in certain cases it may be tinted (e.g. some metals).

#### The Phong reflection

In the Phong model, **the mirror reflection direction $r$ is first computed**.

The vector $\omega_r$ can be:

1. **Constant** for parallel projections
2. The **normalized difference between the point on the surface** $x$ and the
   **center of projection** $c$

This model **accounts for the angular distance** $\alpha$ between $r$ and
$\omega_r$: it computes the **intensity of the specular reflection from the
cosine of the distance**. This way the **specular is maximum if it is aligned
with the observer** and 0 if the angle is $\geq 90^\circ$. To create **more
contained highlights, $\cos\alpha$ is raised to an exponent** $\gamma$: the
greater $\gamma$ is, the smaller the highlight is and the shinier the object
appears.

To compute the direction of the reflected ray first we compute the projection of
the light vector over the normal vector $n' = n_x \cdot (d\cdot n_x)$. If we
subtract $n'$ from $d$ we obtain a vector from $d$ to $n$ perpendicular to $n$.
If we add $2d'$ to $d$ we obtain the reflected vector. **To summarize**:

$$
\begin{aligned}
  r &= d + 2(n_x\cdot (d\cdot n_x) - d) = 2n_x \cdot (d\codt n_x) - d \\
    &= 2n_x \cdot (\vec{xl}\cdot n_x) - \vec{xl}
\end{aligned}
$$

**Many shading languages have this operation builtin**. To do the above in GLSL
we can do `-reflect(xl, n_x)`.

To compute the **intensity of the specular reflection** term we do something
**similar as we did for the Lambert diffuse term**:

$$
  \mathrm{COS}^\gamma \alpha = \mathit{clamp}(\omega_r \cdot r)^\gamma
$$

#### Simplified parametrization

Since most diffuse and specular light models depend on the direction of the
normal vector and a main color, we can simplify the BRDFs as such:

$$
f_D (l, n, v, m_D) \quad f_S(l, n, v, m_S)
$$

Where:

- $l$ is the direction of the light
- $n$ is the direction of the normal vector
- $v$ is the view direction
- $m_*$ are the other model specific parameters

#### Blinn reflection model

The Blinn reflection model is an **alternative to the Phong one**. It uses the
**half vector** $h$: a vector that is the **bisector of the angle between the
viewer direction $\omega_r$ and the light $d$**. The angle $\alpha$ between the
observer and the reflected ray is then **approximated by the angle $\alpha'$
between the normal vector $n_x$ and the half vector $h$**.

$$
h_{l,x} = \mathit{normalize}(\vec{lx} + \omega_r)
$$

The **specular highlight is computed raising to a power $\gamma$ the cosine** of
$\alpha' = n_x\cdot h_{l,x}$.

The Blinn specular model is usually **slightly more expensive than the Phong
one**, but still easily achievable in real-time by current hardware. The Blinn
model usually has a **larger decay area** than the Phong one with similar
parameters.

#### Ward model (anisotropic reflections)

Some objects are characterized by **grooves on their surface** (e.g. hair, disks
or brushed metals). In this case, **specular highlights are oriented along the
grooves**. This surfaces are called **anisotropic**.

This specular model is **derived from physical principles** and **supports both
normal and anisotropic materials**.

To support anisotropy, **an orientation of the grooves on the surface must be
specified**: this is **done by assigning two extra vectors** beside the normal
(the **tangent** $t$ and **bitangent** $b$). Similarly to the Blinn model, it
**computes the half-vector and then computes the angles between**:

1. This **vector and the normal** ($\delta$)
2. The **projection on the $bt$-plane and the groove direction** ($\phi$)

The **formula** is quite complex and can be **found on** `L15.59`.

### Toon shader

Toon shading simplifies the output color range, **using only discrete values
according to a set of thresholds**. In this way it achieves a cartoon-like
rendering style.

It **can be used both for the diffuse and specular components** of the BRDF:

- For Lambert diffuse, we **define two colors** $m_D1, m_D2$ **and a threshold**
  $t_D$ **for determining which color we choose**:

  $$
    f_{diffuse}(\cdot) =
    \begin{cases}
      m_D1 & \quad \vec{lx}\cdot n_x \geq t_D \\
      m_D0 & \quad 0 < \vec{lx}\cdot n_x < t_D \\
      0    & \quad \vec{lx}\cdot n_x < 0
    \end{cases}
  $$

- For the specular we can **use either Phong or Blinn with $\gamma = 1$**, we
  **define a color** $m_S$ and **a threshold** $t_S$ for **determining the color
  we choose**:

  $$
    f_{specular}(\cdot) =
    \begin{cases}
      m_S & \quad \omega_r\cdot r_{l,x} \geq t_S \\
      0   & \quad \omega_r\cdot r_{l,x} < t_S
    \end{cases}
  $$

To achieve **better results**, **more than two colors are used for both the
specular and diffuse parts**. Moreover **small gradients are added to smooth the
transitions** between different colors. This is **usually implemented by using a
color that is function of the cosine of the angles between the considered
rays**.

**Functions are implemented as 1D textures** since texture-lookup is much faster
than branching.

### Cook-Torrance model

Real objects have a soft fall-off area, our reflection models produce very sharp
ones. Moreover, due to the Fresnel principle, objects tend to have a larger
specular reflection when the light is almost parallel to the surface. These and
other effects motivated the introduction of **more complex specular illumination
models that can better capture these features**. The Cook-Torrance reflection
model aims at **computing both the specular and diffuse components in a physical
accurate way**.

The **diffuse component follows the Lambert diffusion model**. However, to
achieve a physically accurate behavior, it is **balanced with the specular part
via linear interpolation**, according to a coefficient $k$:

$$
f_r(\cdot) = k f_{diffuse}(\cdot) + (1-k)f_{specular}(\cdot)
           = m_D \cdot\mathit{clamp}(\vec{lx}\cdot n_x) + (1-k)f_{specular}(\cdot)
$$

The **specular term is computed as the product of three terms**:

- $F$: the **Fresnel** term
- $G$: the **geometric** term
- $D$: the **distribution** term

$$
f_{specular}(\cdot) = m_S
  \frac{D\cdot F\cdot G}{4\cdot\mathit{clamp}(\omega_r\cdot n_x)}
$$

The model uses a **$\rho$ parameter** to indicate **how rough the material** is:
$\rho = 0$ is a perfectly smooth material while $\rho = 1$ is a perfectly
diffuse material.

**Each of the three terms has different implementation**, we will see only the
most used for each. Many formulation use the half-vector defined in the Blinn
model.

#### Distribution term

It accounts for the **roughness of the surface**.

The **Blinn version adapts the one used in the Blinn model** to the
Cook-Torrance framework. In particular it replaces $\gamma$ with $\rho$ and adds
a normalization term.

$$
D = \frac{(h_{l,x}\cdot n_c)^{\frac{2}{\rho^2}-2}}{\pi\cdot\rho^2}
$$

The **Beckmann version uses $\rho$ to define the average slope of the surface at
a microscopic level**.

$$
\begin{gathered}
  \alpha = \cos^{-1}(h_{l,x}\cdot n_x) \\
  D = \frac{e^{-\left(\frac{\tan\alpha}{\rho}\right)^2}}{\pi\rho^2\cos^4\alpha}
\end{gathered}
$$

The **GGX** version uses the following definition:

$$
D = \frac{\rho^2}{\pi(\mathrm{clamp}(n_x\cdot h_{l,x})^2 (\rho^2 -1)+1)^2}
$$

It has been proven to **provide the most realistic results which keeping
realtime complexity**.

#### Fresnel term

The Fresnel term **depends on** $F_0\in [0;1]$, a parameter that **defines how
light reacts depending on the angle of incidence**. It can be **approximated
with the following definition**:

$$
F=F_0 + (1-F_0)(1-\mathrm{clamp}(\omega_r\cdot h_{l,x}))^5
$$

This version **does not work well for conductor materials**, which require an
extended version for a proper representation. That formula however, is too
complex and outside our scope.

#### Geometric term

The **microfacet version** of the geometric term G, is not characterized by any
parameters and **depends only on the angles**.

$$
G = \min\left(1,
      \frac{2(h_{l,x}\cdot n_x)(\omega_r\cdot n_x)}{\omega_r\cdot h_{l,x}},
      \frac{2(h_{l,x}\cdot n_x)(\vec{lx}\cdot n_x)}{\omega_r\cdot h_{l,x}}
\right)
$$

The **GGX version** for the geometric term **depends on the roughness of the
surface** and uses a helper function that is called first with the light and
then with the view direction.

$$
\begin{gathered}
  g_{GGX}(n,a) = \frac{2}{1+\sqrt{1+\rho^2 \frac{1-(n\cdot a)^2}{(n\codt a)^2}}} \\
  G = g_{GGX}(n_x, \omega_r)\cdot g_{GGX}(n_x, \vec{lx})
\end{gathered}
$$

## Material emission

The emission term of a material **accounts for small amounts of light emitted
directly by an object** and corresponds to the emissive part of the rendering
equation.

The emission term is **summed to the other parts of the rendering equation**.
The main difference with ambient light is that **it does not depend on the
environment** but only on the considered object. For Phong we have:

$$
L(x, \omega_r) =
  \mathrm{clamp}(l_d\cdot (m_D\cdot\mathrm{clamp}(d\cdot n_x) +
  m_S\cdot\mathrm{clamp}(\omega_r\cdot r_X)^\gamma) + m_E)
$$

**Realistic rendering techniques try also to consider indirect lighting**, i.e.
illumination caused by light bounces from other objects. **Ambient lighting is
the simplest approximation for indirect illumination**.

### Ambient light

The ambient light emission is specified by a **constant RGB color value** $l_A$.

The BRDF of the object is then **extended by adding another component**
$f_A(x, \omega_r)$ that considers ambient lighting. Such component **does not
depend on the light direction**.

$$
L(x, \omega_r) = \sum_l L(l, \vec{lx})f_r(x, \vec{lx}, \omega_r) + l_a f_a(x, \omega_r)
$$

**In most cases the BRDF for the ambient term is a constant known as the ambient
light reflection color** $m_A$. Generally, $m_A$ corresponds to the main color
of the object, but it can be tuned to obtain special lighting for particular
objects.
