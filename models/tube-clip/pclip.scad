tubeId = 15.25;
clampLength = 14;
clipThickness = 2;
clipRidgeWidth = 5;
clipRidgeGap = 10;
lipRadius = 0.5;
eps = 0.01;

$fn = 20;

module pClipVolumeProfile() {
  circle(tubeId / 2 + clipThickness);
  translate([(tubeId / 2 + clipThickness + clipRidgeWidth) / 2, 0])
    square([tubeId / 2 + clipThickness + clipRidgeWidth, clipRidgeGap + clipThickness * 2], true); module lip() {
    translate([tubeId / 2 + clipThickness + clipRidgeWidth - lipRadius, clipRidgeGap / 2 + clipThickness])
      circle(lipRadius);
  }
  lip();
  scale([1, -1]) lip();
}

module pClipNegative() {
  module cornerChamfer() {
    color("purple")
      translate([tubeId / 2 + clipThickness + clipRidgeWidth, clipRidgeGap / 2])
        polygon(
          [
            [eps, -eps],
            [eps, clipThickness + eps],
            [-clipThickness + eps, -eps],
          ],
        );
  }

  module lipNegative() {
    translate([tubeId / 2, clipRidgeGap / 2])
      circle(lipRadius);
  }

  circle(tubeId / 2);
  translate([(tubeId / 2 + clipThickness + clipRidgeWidth) / 2, 0])
    square([tubeId / 2 + clipThickness + clipRidgeWidth + 2 * eps, clipRidgeGap], true);
  cornerChamfer();
  scale([1, -1, 1]) cornerChamfer();
  lipNegative();
  scale([1, -1, 1]) lipNegative();
}
module pClipProfile() {
  difference() {
    pClipVolumeProfile();
    pClipNegative();
  }
}

module pClip() {
  translate([0, 0, -clampLength / 2])
    linear_extrude(clampLength)
      pClipProfile();
}

pClip();
//pClipVolumeProfile();
