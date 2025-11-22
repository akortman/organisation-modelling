include <bin.scad>
include <../../submodules/gridfinity_extended_openscad/modules/module_gridfinity_label.scad>

xclearance = 0.5;
yclearance = 1.0;

/**
 * Stack cylinders together.
 * Argument must be a list of the form: [[diameter, length], ...]
 */
module cylinderStack(arg, peps = 0, neps = 0) {
  if (len(arg) != 0) {
    radius = arg[0][0] / 2;
    length = arg[0][1];
    translate([0, 0, -neps])
      cylinder(length + peps + neps, radius, radius);
    translate([0, 0, length]) cylinderStack(partial(arg, 1, len(arg) - 1), peps, neps);
  }
}

module driverCutout() {
  rotate([-90, 0, 0])
    cylinderStack(
      [
        [19 + xclearance * 2, 96 + yclearance],
        [12 + xclearance * 2, 24],
        [8 + xclearance * 2, 30 + yclearance],
      ],
      peps=yclearance / 2,
      neps=yclearance / 2,
    );
}

module fingerCutout() {
  fingerCutoutDepth = 10;
  translate([0, 75, -fingerCutoutDepth])
    linear_extrude(20)
      offset(r=4)
        offset(delta=-4)
          square([45.5, 21], true);
}

module extensionCutout() {
  rotate([-90, 0, 0])
    cylinderStack(
      [
        [10 + xclearance * 2, 32 + yclearance],
        [6 + xclearance * 2, 65],
        [10 + xclearance * 2, 18],
        [5 + xclearance * 2, 15 + yclearance],
      ],
      peps=yclearance / 2,
      neps=yclearance / 2,
    );
}

module adapterCutout() {
  rotate([-90, 0, 90]) translate([0, 0, -(25 + 2 * yclearance) / 2]) cylinder(25 + 2 * yclearance, 7 / 2 + xclearance, 7 / 2 + xclearance);
}

module hexBitCutout() {
  rotate([-90, 0, 90]) translate([0, 0, -(30 + 2 * yclearance) / 2]) cylinder(30 + 2 * yclearance, 5 / 2 + xclearance, 5 / 2 + xclearance);
}

module bitStorageBoxCutout(r = 0.5) {
  color("red")
    linear_extrude(30)
      offset(r=r) offset(delta=-r)
          square([43 + 2 * xclearance, 12], true);
}

module binStorageCutout(spacing = 28, angle = 35, numBoxes = 9) {
  for (i = [0:numBoxes - 1])
    translate([0, i * spacing, 0])
      rotate([angle - 90, 0, 0])
        bitStorageBoxCutout();
}

module binStorageSupport(spacing = 28, angle = 35, numBoxes = 9, r = 1) {
  intersection() {
    color("purple")for (i = [0:numBoxes - 1])
      translate([0, i * spacing, 0])
        rotate([angle - 90, 0, 0])
          translate([0, 12, 0])
            minkowski() {
              linear_extrude(24 - 2 * r)
                square([43 - 2 * r, 12 - 2 * r], true);
              sphere(r);
            }
    translate([0, 0, -10.5])
      linear_extrude(500)
        square([500, 500], true);
  }
}

module driverStorageBin() {
  binStoragePos1 = [0, 54, -5];
  binStoragePos2 = [49 - 1.6, 26, -5];
  difference() {
    union() {
      bin();
      translate(binStoragePos1) binStorageSupport(numBoxes=4);
      translate(binStoragePos2) binStorageSupport(numBoxes=5);
    }
    // cutout for extra bits and adapter
    color("red") translate([-47, 0, 0]) fingerCutout();
    color("red") translate([-56, 10.5, 0]) driverCutout();
    color("red") translate([-31.5, 10.5, 0]) extensionCutout();
    translate([0, 2, 0]) {
      color("red") translate([0, 14, 0]) adapterCutout();
      color("red") translate([0, 28, 0]) hexBitCutout();
      color("red") translate([0, 35, 0]) hexBitCutout();
      color("red")
        translate([0, 49 / 2, -3])
          linear_extrude(10)
            offset(r=2)
              offset(delta=-2)
                square([14, 42], true);
    }
    translate(binStoragePos1) binStorageCutout(numBoxes=4);
    translate(binStoragePos2) binStorageCutout(numBoxes=5);
    //translate([28 + 3.5, 10.5, 0]) label_cullenect_socket(abelSize=[36.3, 11.3, 1.5]);
    translate([binStoragePos2[0], 12, -7 * 3 / 4])
      linear_extrude(20) offset(r=2) offset(delta=-2) square([42, 14], true);
  }
  //translate(binStoragePos1) binStorageCutout(numBoxes=4);
  //translate(binStoragePos2) binStorageCutout(numBoxes=5);
}

driverStorageBin();
