/* [Main Parameters] */
// A description of this parameter set (when using the customizer).
description = "";
// The inner diameter of the clip (mm). Recommend 0.25 smaller than the tube (if using PETG).
clipId = 15.25;
// The position of the snap relative to the tube centre (mm).
snapPosition = [25, 6];
// Whether the tube is above or below the snap. This will rotate the "KYZ" text accordingly.
tubePosition = "below"; // ["above", "below"]

/* [Clip Strength] */
// Thickness of the tube clip (mm).
clipThickness = 2.5;
// Outward length of the flat extensions away from the tube (mm).
clipExtWidth = 5;
// Gap between the two flat extensions (mm).
clipExtGap = 10;
// Radius of the small lip at the end of the extensions (mm).
lipRadius = 0.5;

/* [Snap Support] */
// How much additional material to add "behind" the kv1 snap (mm).
snapSupportAmount = 4;
// How much to remove from the snap-to-clip support structure internally to reduce total amount of filament. 0=no hole, larger=hollow out the centre. Recommend 0.65. This is not a size in mm.
snapSupportHoleSize = 0.65; // [0:0.05:0.8]

module __end_of_customiser_opts__(){}

// Length of the clip (mm).
clipLength = 24.8;

// The width of the kv1 snap.
snapWidth = 24.8;

// Push pin configuration
pushPinLength = clipExtGap + 2 * clipThickness;
pushPinDiameter = 4;
pushPinEndSize = [1, 0.6]; // [x, y] or [axial, radial]
pushPinClearance = 0.05;
pushPinTipClearance = 0; // this can be negative for an interference/loaded fit
pushPinWallThickness = 1;

// Fixed value for making things just a tiny bit larger/smaller.
eps = 0.01;

include <BOSL2/std.scad>;

$fn = 40;
$fa = 0.5;

module clipVolumeProfile() {
  circle(clipId / 2 + clipThickness);
  translate([(clipId / 2 + clipThickness + clipExtWidth) / 2, 0])
    square([clipId / 2 + clipThickness + clipExtWidth, clipExtGap + clipThickness * 2], true); module lip() {
    translate([clipId / 2 + clipThickness + clipExtWidth - lipRadius, clipExtGap / 2 + clipThickness])
      circle(lipRadius);
  }
  lip();
  scale([1, -1]) lip();
}

module clipNegativeProfile() {
  module cornerChamfer() {
    color("purple")
      translate([clipId / 2 + clipThickness + clipExtWidth, clipExtGap / 2])
        polygon(
          [
            [eps, -eps],
            [eps, clipThickness + eps],
            [-clipThickness + eps, -eps],
          ],
        );
  }

  circle(clipId / 2);
  translate([(clipId / 2 + clipThickness + clipExtWidth) / 2, 0])
    square([clipId / 2 + clipThickness + clipExtWidth + 2 * eps, clipExtGap], true);
  cornerChamfer();
  scale([1, -1, 1]) cornerChamfer();
}

module clipProfile() {
  rotate([0, 0, -90])
    difference() {
      clipVolumeProfile();
      clipNegativeProfile();
    }
}

module snap() {
  rotate([90, tubePosition == "below" ? 90 : -90, 0])
    translate([0, -28 / 2, 0])
      import("./kv1.stl");
}

module clip() {
  translate([0, 0, -clipLength / 2])
    linear_extrude(clipLength)
      clipProfile();
}

module clipNegative() {
  rotate([0, 0, -90])
    translate([0, 0, -clipLength / 2 - eps])
      linear_extrude(clipLength + 2 * eps)
        clipNegativeProfile();
}

module supportStructureProfile(k = 500) {
  module clipSupports() {

    intersection() {
      projection() clip();
      // we need to select what parts of the p clip we want to use for support
      // if snap is projected significantly +y, cut away all -y
      translate(snapPosition.y >= clipId / 2 ? [0, k / 2] : [0, 0])
        square([k, k], true);
    }
  }

  intersection() {
    hull() {
      clipSupports();
      projection() {
        // Place the snap in the correct position.
        translate([snapPosition.x, snapPosition.y, 0]) snap();
        // Capture the profile of the snap, extrude it into the opposite direction to create a support of the exact
        // required size.
        translate([snapPosition.x, snapPosition.y, 0]) rotate([-90, 0, 0])
            translate([0, 0, -snapSupportAmount])
              linear_extrude(snapSupportAmount)
                projection() rotate([90, 0, 0])
                    snap();
      }
    }
    // cut away part above the snap
    translate([0, -k / 2 + snapPosition.y])
      square([k, k], true);
    // if snap is to the +x, cut away the -x side of the supports
    if (snapPosition.x >= snapWidth / 2)
      translate([k / 2, 0])
        square([k, k], true);
    // if snap is to the -x, cut away the +x side of the supports
    if (snapPosition.x <= -snapWidth / 2)
      translate([-k / 2, 0])
        square([k, k], true);
  }
}

module lightweightSupportStructureProfile(snapSupportHoleSize = 0.5, k = 500) {
  assert(snapSupportHoleSize >= 0 && snapSupportHoleSize <= 1);
  difference() {
    supportStructureProfile(k);
    translate([0, -clipExtWidth / 1.8, 0])
      scale(snapSupportHoleSize)
        supportStructureProfile(k);
  }
}

module snapClearance(clearance = 4.5, snapHeight = 5, snapWidth = 24.8) {
  difference() {
    translate([0, (snapHeight + clearance) / 2, 0])
      cube([snapWidth + clearance * 2, snapHeight + clearance, snapWidth + clearance * 2], true);
    snap();
  }
}

module tubeClip(supportWidth = snapWidth) {
  difference() {
    union() {
      clip();
      translate([snapPosition.x, snapPosition.y, 0]) snap();
      translate([0, 0, -supportWidth / 2])
        linear_extrude(supportWidth) color("purple") lightweightSupportStructureProfile(snapSupportHoleSize);
    }
    translate([snapPosition.x, snapPosition.y, 0]) snapClearance();
    clipNegative();
    pushPinNegative();
  }
}

module pushPinNegative() {
  color("red") {
    translate([pushPinLength / 2 + eps, -clipId / 2 - clipExtWidth / 2, 0])
      rotate([0, -90, 0]) {
        cylinder(pushPinLength + eps, pushPinDiameter / 2 + eps, pushPinDiameter / 2 + eps);
        cylinder(pushPinEndSize.x + 2 * eps, pushPinDiameter / 2 + pushPinEndSize.y + eps, pushPinDiameter / 2 + pushPinEndSize.y + eps);
      }
  }
}

module pushPin(k = 200, wedgePosition = 0.6) {
  module base() {
    color("purple") {
      //main tube body
      translate([0, 0, eps])
        cylinder(pushPinLength + eps, pushPinDiameter / 2 - pushPinClearance, pushPinDiameter / 2 - pushPinClearance);
      // cap
      translate([0, 0, pushPinLength])
        cylinder(pushPinEndSize.x - 2 * pushPinClearance, pushPinDiameter / 2 + pushPinEndSize.y - pushPinClearance, pushPinDiameter / 2 + pushPinEndSize.y - pushPinClearance);
      // spiky end
      translate([0, 0, (pushPinEndSize.x - 2 * pushPinClearance) / 2])
        cylinder(
          (pushPinEndSize.x - 2 * pushPinClearance) / 2,
          pushPinDiameter / 2 - pushPinTipClearance + pushPinEndSize.y,
          pushPinDiameter / 2 - pushPinTipClearance + pushPinEndSize.y,
        );
      cylinder(
        (pushPinEndSize.x - 2 * pushPinClearance) / 2,
        pushPinDiameter / 2 - pushPinTipClearance + pushPinEndSize.y / 2,
        pushPinDiameter / 2 - pushPinTipClearance + pushPinEndSize.y,
      );
    }
  }

  module wedge1Negative(wedgeWidth = 1 / 4) {
    x = pushPinLength * wedgePosition + eps;
    y = pushPinDiameter * wedgeWidth / 2;
    translate([0, 0, pushPinLength * wedgePosition])
      rotate([0, 90, 0])
        translate([0, 0, -k / 2])
          linear_extrude(k)
            polygon([[0, 0], [x, y], [x, -y]]);
  }

  module wedge2Negative(off, a) {
    x = pushPinDiameter / 2 + pushPinEndSize.x;
    y = 0.5 * x * tan(a);
    module profile() {
      polygon([[off, 0], [x, y], [x, -y]]);
    }
    translate([0, 0, -eps]) linear_extrude(2 * eps) profile();
    linear_extrude(pushPinLength * wedgePosition / 2, scale=[1, 0]) profile();
  }

  module roundedEndNegative() {
    roundedEndSize = 0.5;
    translate([0, 0, -roundedEndSize + pushPinEndSize.x - pushPinClearance * 2])
      rotate_extrude()
        translate([pushPinDiameter / 2 - roundedEndSize - pushPinClearance + pushPinEndSize.x, 0, 0])
          difference() {
            square(roundedEndSize + eps);
            circle(roundedEndSize + eps);
          }
  }

  translate([pushPinLength / 2, -clipId / 2 - clipExtWidth / 2, 0])
    rotate([0, -90, 0])
      difference() {
        base();
        // inner cylinder cutout
        //translate([0, 0, -eps])
        //  cylinder(
        //    pushPinLength + eps,
        //    pushPinDiameter / 8,
        //    pushPinDiameter / 8,
        //  );
        // cutout cone on end
        translate([0, 0, -eps])
          cylinder(
            // length
            pushPinLength / 2,
            // radius at base
            pushPinDiameter / 5,
            0,
          );
        wedge1Negative(0.22);
        rotate([0, 0, 90]) wedge1Negative(0.22);

        for (a = [0, 90, 180, 270]) rotate([0, 0, a]) wedge2Negative(1.0, 40);
        for (a = [0, 90, 180, 270]) rotate([0, 0, a]) wedge2Negative(2, 70);

        roundedEndNegative();
      }
}

// position the clip and push pin according to how they are intended to be printed.
translate([0, 0, max(snapWidth, clipLength) / 2]) tubeClip();
translate([0, -10, pushPinLength / 2 + pushPinEndSize.x]) rotate([0, -90, 0]) pushPin();
