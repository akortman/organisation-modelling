include <BOSL2/std.scad>;

tubeId = 15.25;
clampLength = 12;
clipThickness = 2;
clipRidgeWidth = 5;
clipRidgeGap = 10;
lipRadius = 0.5;
lockingRingRadius = 0.25;

snapXOffset = 25;
snapYOffset = 2.5;
eps = 0.01;
screwHoleSize = 3;
screwHoleDepth = clipRidgeGap + clipThickness * 2 + eps * 2;

$fn = 20;

module pClipVolumeProfile() {
  circle(tubeId / 2 + clipThickness);
  translate([(tubeId / 2 + clipThickness + clipRidgeWidth) / 2, 0])
    square([tubeId / 2 + clipThickness + clipRidgeWidth, clipRidgeGap + clipThickness * 2], true); module cornerChamfer() {
    translate([tubeId / 2 + 2 * clipThickness + clipRidgeWidth - lipRadius, -clipRidgeGap / 2 - clipThickness])
      difference() {
        circle(lipRadius);
        translate([-lipRadius, 0])
          square([lipRadius * 2, lipRadius]);
      }
    color("purple")
      translate([tubeId / 2 + clipThickness + clipRidgeWidth, -clipRidgeGap / 2])
        polygon(
          [
            [0, 0],
            [0, -clipThickness],
            [clipThickness, -clipThickness],
          ],
        );
  }
  cornerChamfer();
}

module pClipNegativeProfile() {
  circle(tubeId / 2);
  translate([(tubeId / 2 + clipThickness + clipRidgeWidth) / 2, 0])
    square([tubeId / 2 + clipThickness + clipRidgeWidth + 2 * eps, clipRidgeGap], true);
}

module pClipProfile() {
  difference() {
    pClipVolumeProfile();
    pClipNegativeProfile();
  }
}

module pClip() {
  translate([0, 0, -clampLength / 2])
    linear_extrude(clampLength)
      pClipProfile();
}

module pClipNegative() {
  translate([0, 0, -clampLength / 2 - eps])
    linear_extrude(clampLength + 2 * eps)
      pClipNegativeProfile();
}

module snap() {
  rotate([90, 0, 0])
    translate([0, -28 / 2, 0])
      import("./kv1.stl");
}

module supportStructureProfile(delta = 0) {
  polygon(
    [
      [snapXOffset + 24.8 / 2 - delta, clipRidgeGap / 2 + clipThickness + snapYOffset - clipThickness + delta],
      [snapXOffset + 24.8 / 2 - delta, clipRidgeGap / 2 + clipThickness + snapYOffset - delta],
      [snapXOffset - 24.8 / 2 + delta, clipRidgeGap / 2 + clipThickness + snapYOffset - delta],
      [snapXOffset - 24.8 / 2 + delta, clipRidgeGap / 2 + clipThickness + snapYOffset - clipThickness + delta],
      [delta, tubeId / 2 + clipThickness - delta],
      [delta, tubeId / 2 + delta],
      [delta, clipRidgeGap / 2 + delta],
      [tubeId / 2 + clipRidgeWidth + clipThickness, clipRidgeGap / 2 + delta],
    ],
  );
}

module supportStructure(delta = 0) {
  difference() {
    translate([0, 0, -clampLength / 2 + delta]) minkowski() {
        linear_extrude(clampLength - 2 * delta) supportStructureProfile(delta=delta);
        sphere(delta);
      }
    pClipNegative();
  }

  translate([snapXOffset, clipRidgeGap / 2 + clipThickness + snapYOffset - 2])
    rotate([90, 0, 0]) linear_extrude(snapYOffset / 2, scale=0) projection() rotate([90, 0, 0]) snap();
}

module screwHole() {
  color("red")
    rotate([90, 0, 0])
      translate([tubeId / 2 + clipRidgeWidth / 2, 0, -screwHoleDepth / 2])
        cylinder(screwHoleDepth, screwHoleSize / 2, screwHoleSize / 2);
}

module snapClip() {
  difference() {
    union() {
      pClip();
      supportStructure(1);
      translate([snapXOffset, clipRidgeGap / 2 + clipThickness + snapYOffset, 0]) snap();
    }
    screwHole();
  }
}

module testPrint() {
  linear_extrude(5) projection() snapClip();
}
;

//snapClip();
testPrint();
