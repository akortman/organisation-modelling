size = [3, 4];
snaps = [
  [false, false, false],
  [true, false, true],
  [true, false, true],
  [true, false, true],
];
depth = 32;
t = 4;
d = 4;
padWidth = 3;
eps = 0.01;
raiseEdge = 0.5;
r = 0.5;
cutoutsStyle = "A";
// All in oG units.
cutoutADepth = 5;
cutoutAHeight = 2.25;
cutoutAPosition = 28 * 1.25;
cutoutBDepth = 0.25;
cutoutBHeight = 2;
cutoutBPosition = 28 * 2;

lowerCutoutStyle = "A";
lowerCutoutAWidth = 1.25;
lowerCutoutADepthMm = depth - 8;
lowerCutoutBWidth = 1.5;
lowerCutoutBHeight = 0.25;

cornerCutoutStyle = "A";
cornerCutoutAWidthMm = 24;
cornerCutoutADepthMm = depth - 8;

$fn = 10;

assert(len(snaps) == size[1]);
for (row = snaps) {
  assert(len(row) == size[0]);
}

include <../../submodules/BOSL2/std.scad>
use <../../submodules/QuackWorks/openGrid/opengrid-snap.scad>
use <../../submodules/QuackWorks/openGrid/opengrid.scad>
use <./grid.scad>

module snapsTransform() {
  translate([(size[0] / 2) * 28, (size[1]) * 28, 0])
    rotate([0, 0, 180])
      gridify(size[0], size[1], snaps)
        children();
}

module snaps() {
  snapsTransform() openGridSnap();
}

module shape(t, r) {
  translate([0, r])
    polygon(
      turtle(
        [
          "move",
          28 / 2 - r + padWidth / 2,
          "arcleft",
          28,
          90,
          "move",
          28 * 4 - r,
          "turn",
          90,
          "move",
          t - r,
          "turn",
          90,
          "move",
          28 * 4,
          "arcright",
          28 - t,
          90,
          "move",
          28 + padWidth / 2,
          "arcright",
          28 - t,
          90,
          "move",
          28 * 4 - r,
          "turn",
          90,
          "move",
          t - r,
          "turn",
          90,
          "move",
          28 * 4 - 2 * r,
          "arcleft",
          28,
          90,
        ],
      ),
    );
}

module angledTopNegative() {
  rotate([90, 0, 90])
    translate([0, 0, -100])
      linear_extrude(200)
        polygon([[28 * 4 - 2, -eps], [28 * (4 + raiseEdge), depth + eps], [28 * 100, depth + eps], [28 * 100, -eps]]);
}

module cutoutBNegativePiece() {
  translate([0, cutoutBPosition, 0]) cutout() square([2 * 28 * cutoutBDepth, 28 * cutoutBHeight], true);
}

module cutout(r = 5, k = 500) {
  color("red")
    translate([0, 0, -k / 2])
      linear_extrude(k)
        offset(r=r) offset(delta=-r)
            children();
}

module cornerCutoutNegativeBase() {
  angle = 50;
  path = turtle(
    [
      "move",
      28 / 2 - r + padWidth / 2,
      "arcleft",
      28,
      angle,
    ],
  );

  pos = path[len(path) - 1];
  translate([pos[0], pos[1], depth / 2]) rotate([90, 0, angle]) cutout(k=20) square([cornerCutoutAWidthMm, cornerCutoutADepthMm], true);
}

module hanger() {
  snaps();
  // project the shape of the snap upwards to ensure it connects to the body of the holder.
  color("red") translate([0, 0, 6.8 / 2 - eps]) snapsTransform() linear_extrude(d / 2 + eps) projection(cut=true) translate([0, 0, -6.8 / 2 + eps]) openGridSnap();
  minkowski() {
    union() {
      // these snap supports shouldn't be cut out
      translate([0, 0, r + 6.8 / 2])
        snapsTransform()
          linear_extrude(d - 2 * r) offset(r=5) offset(delta=-5) square(26, 26);
      difference() {
        union() {
          translate([0, 0, r]) linear_extrude(depth - 2 * r) shape(d - 2 * r, r);
          translate([0, 0, depth - d + r]) linear_extrude(d - 2 * r) shape(14, r);
          hull() translate([0, 0, r]) linear_extrude(d - 2 * r) shape(28, r);
        }
        angledTopNegative(); if (cutoutsStyle == "A") {
          translate([0, cutoutAPosition + 28 * cutoutAHeight / 2, depth / 2])
            rotate([0, 90, 0])
              cutout()
                square([depth - 2 * cutoutADepth, 28 * cutoutAHeight], true);
        }
        if (cutoutsStyle == "B") {
          translate([-28 * 1.5 - padWidth / 2, 0, 0]) cutoutBNegativePiece();
          translate([28 * 1.5 + padWidth / 2, 0, 0]) cutoutBNegativePiece();
        }
        if (lowerCutoutStyle == "A") {
          translate([0, 0, depth / 2])
            rotate([90, 0, 0])
              cutout(r=min(5, lowerCutoutADepthMm / 2 - eps))
                square([28 * lowerCutoutAWidth, lowerCutoutADepthMm], true);
        }
        if (lowerCutoutStyle == "B") {
          cutout() square([28 * lowerCutoutBWidth, 28 * lowerCutoutBHeight * 2], true);
        }
        if (cornerCutoutStyle == "A") {
          cornerCutoutNegativeBase();
          scale([-1, 1, 1]) cornerCutoutNegativeBase();
        }
        // back cutout
        translate([0, 28 * 2, 0])
          cutout(r=5)
            square([21, 28 * 2.5], true);
      }
    }
    sphere(r);
  }
}

hanger();
