d = 28;
boardThickness = 6.8;
eps = 0.01;
t = 0.5;
sidesLite = true;
topLite = false;
sidePanelSize = [2, 2];

Chamfer_Top_Right = false;
include <../../submodules/BOSL2/std.scad>
use <../../submodules/QuackWorks/openGrid/opengrid-snap.scad>
use <../../submodules/QuackWorks/openGrid/opengrid.scad>

$fn = 10;
$fa = 0.5;

module snap() {
  translate(topLite ? [0, 0, 6.8 - 4] : [0, 0, 0])
    openGridSnap(topLite);
}

module plate(w, h, center = false) {
  translate(center ? [-d * w / 2, -d * h / 2, 0] : [0, 0, 0]) {
    for (x = [0:w - 1]) {
      for (y = [0:h - 1]) {
        translate([d * x, d * y, -boardThickness / 2])
          translate([d / 2, d / 2, 0])
            snap();
      }
    }
    cube([d * w, d * h, t + eps]);
  }
}

module wallmount() {
  fillHoles = [
    [[22, 22, 0], 8.5],
    [[22, -22, 0], 8],
    [[2, 0, 0], 7.2],
  ];
  fillRadius = 12;
  translate([3.422, 0, t]) {
    translate([-62.845 / 2, -79.8 / 2, 0]) import("./charger-wallmount.stl");
    color("red")for (f = fillHoles) {
      translate(f[0]) cylinder(f[1], fillRadius / 2, fillRadius / 2);
    }
  }
}

module sidePanel(chamfers = "Corners", connector_holes = false) {
  color("green") if (sidesLite) {
    translate([0, 0, -4 / 2]) openGridLite(sidePanelSize[0], sidePanelSize[1], Chamfers=chamfers, Connector_Holes=connector_holes);
  } else {
    translate([0, 0, -6.8 / 2]) {
      openGrid(sidePanelSize[0], sidePanelSize[1], Chamfers=chamfers, Connector_Holes=connector_holes);
      translate([-28, 0, -6.8 / 2]) cube([28, 28, 6.8]);
    }
  }
}

module sidePanelCutouts() {
  w = 28 * sidePanelSize[0] - 2 * eps;
  h = 28 * sidePanelSize[1] - 2 * eps;
  t = sidesLite ? 4 : 6.8;
  difference() {
    translate([-w / 2, -h / 2, -t])
      cube([w, h, t - 2 * eps]);
    sidePanel(chamfers="none");
  }
}

module chargerProfileSide() {
  rotate([-90, 0, 0]) projection(cut=false) rotate([90, 0, 0]) wallmount();
}
module chargerProfileFront() {
  projection(cut=false)
    rotate([0, 90, 0]) wallmount();
}

module chargerHolder() {
  cableManagementCutoutDiameter = 4;
  sideCableManagementCutoutDiameter = 8;

  module sp1Location() {
    translate([0, 28 * 1.5, 28 * sidePanelSize[1] / 2]) rotate([90, 180, 180]) children();
  }
  module sp2Location() {
    translate([0, -28 * 1.5, 28 * sidePanelSize[1] / 2]) rotate([90, 180, 0]) children();
  }

  fillRadius = 40;
  module cornerFill() {
    linear_extrude(28 * 2)
      translate([-fillRadius, -fillRadius])
        difference() {
          square([fillRadius, fillRadius]);
          color("red") circle(fillRadius);
        }
  }

  difference() {
    union() {
      plate(2, 3, center=true);
      wallmount();
      sp1Location() sidePanel();
      sp2Location() sidePanel();

      // fill corners
      difference() {
        union() {
          translate([-28, -1.5 * 28 + (sidesLite ? 4 : 6.8), 0])
            translate()
              rotate([0, 0, 180])
                cornerFill();
          translate([-28, 1.5 * 28 - (sidesLite ? 4 : 6.8), 0])
            translate()
              rotate([0, 0, 90])
                cornerFill();
        }
        // remove a chamfer to match the sides
        color("red")
          translate([-28, 1.5 * 28, 28 * 2])
            rotate([0, -90, 90])
              linear_extrude(28 * 3)
                polygon(
                  [
                    [eps, eps],
                    [-4.2 - eps, eps],
                    [eps, -4.2 - eps],
                  ],
                );
        // cable management cutouts
        //color("purple") {
        //    translate([-28/2, -28*1.5 + (sidesLite ? 4 : 6.8), -eps])
        //    cylinder(28*3 + eps, sideCableManagementCutoutDiameter/2, sideCableManagementCutoutDiameter/2);
        //}
        //color("purple") {
        //    translate([-28/2, 28*1.5 - (sidesLite ? 4 : 6.8), -eps])
        //    cylinder(28*3 + eps, sideCableManagementCutoutDiameter/2, sideCableManagementCutoutDiameter/2);
        //}
      }
    }
    sp1Location() sidePanelCutouts();
    sp2Location() sidePanelCutouts();
    // cable management cutouts
    color("purple")
      translate([-28, -28 / 2, -eps])
        cylinder(28 * 3 + eps, cableManagementCutoutDiameter / 2, cableManagementCutoutDiameter / 2);
    color("purple")
      translate([-28, 28 / 2, -eps])
        cylinder(28 * 3 + eps, cableManagementCutoutDiameter / 2, cableManagementCutoutDiameter / 2);
  }
}

chargerHolder();
