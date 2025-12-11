include <core.scad>;

module base() {
  module snaps() {
    module snap() {
      translate([0, 0, -6.8 / 2])
        rotate([0, 0, -90])
          openGridSnap(directional=false);
    }
    numSnaps = 3;
    translate([-numSnaps / 2 * 28 + 28 / 2, 28 / 2, 0])for (i = [0:numSnaps - 1]) translate([28 * i, 0, 0]) snap();
  }
  translate([0, 3.2 / 2, 0]) {
    snaps();
    translate([0, 0, -eps])
      linear_extrude(baseThickness + eps)
        hull()
          projection(true)
            translate([0, 0, eps]) snaps();
  }
}

module main() {
  difference() {
    union() {
      difference() {
        translate([0, -28, 0]) base();
        xSmoothingNegativeBaseOnly();
      }
      translate([0, 0, baseThickness]) cradle();
    }
    xSmoothingNegative();
    zSmoothingNegative();
  }
}

main();
