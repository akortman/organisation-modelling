baseThickness = 2.5;
cradleThickness = 3.5;
flareOd = 78.5;
flareHeight = 25.5;
flareDepth = 10;
portafilterOd = 70;
additionalUpperWallSize = 24.8 - flareHeight / 2 - cradleThickness;

eps = 0.01;

$fn = 80;
$fa = 0.5;

include <BOSL2/std.scad>
use <../../submodules/QuackWorks/openGrid/opengrid-snap.scad>

module smoother(r, pos = [0, 0]) {
  translate([-r, -r] + pos)
    difference() {
      square(r);
      circle(r);
    }
}

module cradle() {
  module mirror() {
    children();
    scale([-1, 1]) children();
  }

  module flareProfile(od, id, height, additionalSideWall = 0) {
    translate([0, -additionalSideWall])
      intersection() {
        difference() {
          circle(od / 2);
          circle(id / 2);
        }
        translate([0, -height / 2])
          square([flareOd + 2 * cradleThickness, height], true);
      }
    module additionalSideWallLeft() {
      color("green") translate([-od / 2, -additionalSideWall]) square([od / 2 - id / 2, additionalSideWall]);
    }
    mirror() additionalSideWallLeft();
  }

  module chamferProfile(chamferSize) {
    polygon(
      [
        [-eps, eps],
        [-eps + chamferSize, eps],
        [-eps, -chamferSize],
      ],
    );
  }

  module negativeVolume(curvature = 1) {
    module negativeProfile(extraHeight = curvature + 1) {
      translate([0, extraHeight - curvature])
        flareProfile(
          od=flareOd - 2 * curvature,
          id=portafilterOd / 2,
          height=flareHeight / 2 - 2 * curvature,
          additionalSideWall=additionalUpperWallSize + extraHeight,
        );
    }

    minkowski() {
      translate([0, 0, curvature - eps])
        linear_extrude(flareDepth - 2 * curvature + 2 * eps) negativeProfile();
      sphere(curvature);
    }

    color("green") linear_extrude(flareDepth) mirror() translate([flareOd / 2, 0]) {
            //translate([-(1+curvature), -(1+curvature)]) square([1+curvature, 1+curvature]);
            translate([-curvature, 0]) chamferProfile(2 * curvature);
          }
  }

  module volume(curvature = 1) {
    module fullProfile() {
      difference() {
        flareProfile(
          od=flareOd + 2 * cradleThickness - 2 * curvature,
          id=portafilterOd + 2 * curvature,
          height=flareHeight / 2 + cradleThickness - 2 * curvature,
          additionalSideWall=additionalUpperWallSize,
        );
        mirror() translate([portafilterOd / 2, 0]) chamferProfile(2);
      }
    }

    minkowski() {
      translate([0, -curvature, -baseThickness + curvature])
        linear_extrude(flareDepth + baseThickness + cradleThickness - 2 * curvature) fullProfile();
      sphere(curvature);
    }
  }

  difference() {
    volume();
    negativeVolume();
  }
}

module xSmoothingNegative(k = 100) {
  module profile() {
    // translations are in plane [z, y] after transforms
    module z(_) translate([_, 0]) children();
    module y(_) translate([0, _]) children();
    module rot(_) rotate([0, 0, -_]) children();
    y(0) z(flareDepth + 2 * baseThickness) rot(0) smoother(baseThickness / 2);
    y( -flareHeight / 2 - additionalUpperWallSize - cradleThickness) z(flareDepth + 2 * baseThickness) rot(90) smoother(baseThickness / 2);
  }
  rotate([0, -90, 0])
    translate([0, 0, -k / 2])
      linear_extrude(k)
        profile();
}

module xSmoothingNegativeBaseOnly(k = 100) {
  module profile() {
    // translations are in plane [z, y] after transforms
    module z(_) translate([_, 0]) children();
    module y(_) translate([0, _]) children();
    module rot(_) rotate([0, 0, -_]) children();
    y(0) z(baseThickness) rot(0) smoother(baseThickness / 2);
    y(-24.8 - eps) z(baseThickness) rot(90) smoother(baseThickness);
  }
  rotate([0, -90, 0])
    translate([0, 0, -k / 2])
      linear_extrude(k)
        profile();
}

module zSmoothingNegative(k = 100) {
  module profile() {
    // translations are in plane [z, y] after transforms
    module x(_) translate([_, 0]) children();
    module y(_) translate([0, _]) children();
    module rot(_) rotate([0, 0, _]) children();
    x(flareOd / 2 + cradleThickness) y(0) smoother(baseThickness / 2);
    x( -flareOd / 2 - cradleThickness) y(0) rot(90) smoother(baseThickness / 2);
  }
  rotate([0, 0, 0])
    translate([0, 0, -k / 2])
      linear_extrude(k)
        profile();
}
