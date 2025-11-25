include <../../submodules/gridfinity_extended_openscad/modules/module_gridfinity_cup.scad>
use <./shadowbox.scad>;
// use <../../submodules/gridfinity_extended_openscad/modules/functions_gridfinity.scad>
use <../../submodules/gridfinity_extended_openscad/modules/module_attachment_clip.scad>
use <../../util/smoothing.scad>

width = 2.5;
depth = 7;
cupHeight = 5;
floorHeight = 2.5; // gf z-units
insertHeightMm = 14;
halfPitch = true;
chamfer = false;
chamferSize = [1.5, 1.5];
chamferLayerSize = 0.1;

$fa = 0.5;
$fn = 30;

floorThickness = max(0.7, floorHeight * 7);

lip_settings = LipSettings(lipStyle=LipStyle_normal);
cupBase_settings = CupBaseSettings(
  halfPitch=halfPitch,
  floorThickness=floorThickness,
);

module profile() {
  tooltraceDxf("./irwin-vice-grips.dxf");
  fingerCutout2d(size=[42 * width - 14, 1.5 * 42]);
}

module insertShapes() {
  translate([width * 42 / 2, depth * 42 / 2, 0]) {
    insertShape(floorHeight, insertHeightMm) profile(); if (chamfer)
      translate([0, 0, 5 + floorThickness])
        chamferFromOutline(chamferSize=chamferSize, layerSize=chamferLayerSize)
          profile();
  }
}

module bin(
  mode = "whole"
) {
  gridfinity_cup(
    width,
    depth,
    cupHeight,
    lip_settings=lip_settings,
    cupBase_settings=cupBase_settings,
    extendable_Settings=ExtendableSettings(
      extendablexEnabled="disabled",
      extendablexPosition=0.5,
      extendableyEnabled=mode == "whole" ? "disabled" : mode,
      extendableyPosition=depth / 4,
      extendableTabsEnabled=true,
      //Tab size, height, width, thickness, style. width default is height, thickness default is 1.4, style {0,1,2}.
      extendableTabSize=[10, 0, 0, 0],
    ),
    wallcutout_horizontal_settings=WallCutoutSettings(
      type="enabled",
      position=-2,
      width=0,
      angle=70,
      height=-1.0,
      corner_radius=5,
    ),
  );
}

module singleBin() {
  difference() {
    bin("whole");
    insertShapes();
  }
}

module twoPieceBin(spacing = 14) {
  difference() {
    bin("back");
    insertShapes();
  }
  translate([0, spacing, 0])
    difference() {
      bin("front");
      insertShapes();
    }
}

difference() {
  bin("back");
  insertShapes();
}
