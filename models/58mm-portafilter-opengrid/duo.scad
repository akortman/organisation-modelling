include <core.scad>;

// each single cradle has total width `flareOd + 2 * cradleThickness`
// they can overlap by up to `cradleThickness - 1`
// so the spacing is: flareOd + 2 * cradleThickness - (cradleThickness - 1) = flareOd + cradleThickness + 1
spacing = flareOd + cradleThickness + 1;

module duoBase() {
  module snaps() {
    module snap() {
      translate([0, 0, -6.8 / 2])
        rotate([0, 0, -90])
          openGridSnap(directional=false);
    }
    numSnaps = 6;
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

module zSmoothingNegativeDuo(k = 100) {
  module profile() {
    // translations are in plane [z, y] after transforms
    module x(_) translate([_, 0]) children();
    module y(_) translate([0, _]) children();
    module rot(_) rotate([0, 0, _]) children();
    x(flareOd / 2 + cradleThickness + spacing / 2) y(0) smoother(baseThickness / 2);
    x( -flareOd / 2 - cradleThickness - spacing / 2) y(0) rot(90) smoother(baseThickness / 2);
  }
  rotate([0, 0, 0])
    translate([0, 0, -k / 2])
      linear_extrude(k)
        profile();
}

module main(k = 100, fill = 10) {
  difference() {
    union() {
      difference() {
        translate([0, -28, 0]) duoBase();
        translate([-spacing / 2, 0, 0])
          xSmoothingNegativeBaseOnly();
        translate([spacing / 2, 0, 0])
          xSmoothingNegativeBaseOnly();
      }

      translate([0, 0, baseThickness]) {
        translate([-spacing / 2, 0, 0]) cradle();
        translate([spacing / 2, 0, 0]) cradle();
        // create a piece to fill the corner between the two flare holders in the middle
        color("yellow")
          intersection() {
            rotate([0, -90, 0])
              translate([0, 0, -fill / 2])
                linear_extrude(fill)
                  projection() rotate([0, 90, 0]) cradle();
            translate([0, 0, -k / 2])
              linear_extrude(k)
                polygon([[0, -additionalUpperWallSize], [fill / 2, -flareHeight], [-fill / 2, -flareHeight]]);
          }
      }
      ;
    }
    xSmoothingNegative();
    zSmoothingNegativeDuo();
  }
}

main();
