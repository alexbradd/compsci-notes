# Computer graphics

## Graphics primitives

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
left, $(1;1)$ in the upper right... this means that the y-axis goes up), while
**Vulkan maintains the convention of the pixel coordinates** (y-axis goes down).

If we know the size of our draw area, we can **derive** the normalized coordinates
using the following **transformation**:

$$\begin{aligned}
  x_s &= \frac{(s_w-1)*(x_n=1)}{2} \\
  y_s &= \frac{(s_h-1)*(y_n=1)}{2} \\
\end{aligned}$$


