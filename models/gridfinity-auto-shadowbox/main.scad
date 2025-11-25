use <./shadowbox.scad>

/* [General Settings] */
mode = "cup"; // [cup:Tray with cutout,negative:Negative only]
displayMode = "preview"; // [normal,preview]

/* [Cup Settings] */
cupWidth = 2.5; // [1:0.5:12]
cupDepth = 7; // [1:0.5:12]
cupHeight = 3; // [1:1:20]

/* [Cutout Settings] */
shape = "irwin-vice-grips.dxf";
chamfer = true;
chamferSize = 2;

/* [Final Render Settings] */
chamferLayerSize = 0.1;

/* [Preview Settings] */
chamferSizePreview = chamferSize;
chamferLayerSizePreview = 0.5;

module __end_of_customizer__(){}
previewMode = displayMode == "preview";
actualChamferSize = !chamfer ? undef : previewMode ? chamferSizePreview : chamferSize;
actualChamferLayerSize = previewMode ? chamferLayerSizePreview : chamferLayerSize;

shadowbox(
  width=cupWidth,
  depth=cupDepth,
  height=cupHeight,
  createNegative=mode == "negative",
) {
  cutout(chamferSize=actualChamferSize, chamferLayerSize=actualChamferLayerSize) {
    tooltraceDxf("irwin-vice-grips.dxf");
    fingerCutout2d();
  }
}
