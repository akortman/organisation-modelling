/**
 * Tools for smoothing & chamfers.
 */

highColour = [166, 255, 250] / 255;
lowColour = [0, 7, 45] / 255;
function interp(a, b, x) = x * a + (1 - x) * (b - a);
module progressiveColour(f) {
  color(interp(lowColour, highColour, f)) children();
}

/**
 * Given an outline shape/polygon as a child, turn it into a chafer negative.
 */
module chamferFromOutline(size = [1, 1], mode = "outer", layers = undef, layerSize = undef, eps = 0.01, upperEps = 1) {
  assert(mode == "outer");
  module embiggen(x) {
    offset(r=x) children();
  }

  layerCount = !is_undef(layers) ? layers
  : !is_undef(layerSize) ? ceil(size[1] / layerSize)
  : $fn;
  zdelta = !is_undef(layers) ? size[1] / layers : size[1] / layerCount;

  for (i = [0:layerCount - 1]) {
    f = i / (layerCount - 1);
    progressiveColour(f)
      translate([0, 0, -size[1]])
        translate([0, 0, min(zdelta * i, size[1] - zdelta)])
          linear_extrude(zdelta + (i == layerCount - 1 ? upperEps : eps) )
            embiggen(size[0] * f)
              children();
  }
}

/**
 * Slice children into layers and hull() each layer.
 * For certain shapes that aren't convex when sliced, this can produce a nice smoothing effect.
 */
module layeredAxialHull(layerSize, bounds) {
  assert(layerSize > 0);
  echo("bounds", bounds); xmin = bounds[0][0];
  xmax = bounds[0][1];
  ymin = bounds[1][0];
  ymax = bounds[1][1];
  zmin = bounds[2][0] ? bounds[2][0] : -2;
  zmax = bounds[2][1] ? bounds[2][1] : 2;
  echo("xmin: ", xmin);
  echo("xmax: ", xmax);
  echo("ymin: ", ymin);
  echo("ymax: ", ymax);
  echo("zmin: ", zmin);
  echo("zmax: ", zmax);

  steps = ceil( (ymax - ymin) / layerSize);
  actualLayerSize = (ymax - ymin) / steps;
  assert(steps < 100);

  module layer(i) {
    f = (i / steps);
    pos = [xmin, ymin + i * actualLayerSize, zmin];
    layerEnvelope = [xmax - xmin, actualLayerSize, zmax - zmin];

    progressiveColour(f)
      intersection() {
        translate(pos) cube(layerEnvelope);
        children();
      }
  }

  for (i = [0:steps - 1]) {
    hull() layer(i) children();
  }
}
