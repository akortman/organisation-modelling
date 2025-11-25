include <../../submodules/gridfinity_extended_openscad/modules/module_gridfinity_cup.scad>
use <../../util/smoothing.scad>

$fa = 0.5;
$fn = 40;

module tooltraceDxf(path, removeOuterEdge = 1) {
  module raw() {
    import(path);
  }
  difference() {
    offset(delta=-removeOuterEdge) hull() raw();
    raw();
  }
}

module removeOuterEdge(edgeSize = 0) {
  intersection() {
    union() children();
    offset(delta=-edgeSize) hull() children();
  }
}

function getAutoRadius(size) = floor(2 * size / 7);

module fingerCutout2d(size = undef, radiusMm = undef) {
  // if size is not provided we estimate a central position
  actualSize = is_undef(size) ? [$num_x - 0.25, min($num_y / 2, 0.75)] : is_num(size) ? [size, size] : size;

  if (is_num(radiusMm)) {
    assert(radiusMm < actualSize[0] / 2);
    assert(radiusMm < actualSize[1] / 2);
  } else {
    assert(is_undef(radiusMm));
  }

  actualRadius = is_undef(radiusMm) ? getAutoRadius(42 * min(actualSize[0], actualSize[1])) : radius;

  echo("actualRadius", actualRadius);
  offset(r=actualRadius) offset(delta=-actualRadius)
      square(42 * actualSize, true);
}

module insertShape(parentHeight, insertHeightMm, eps = 1) {
  translate([0, 0, parentHeight * 7 - insertHeightMm + 4.75])
    linear_extrude(insertHeightMm + eps)
      children();
}

module shadowbox(
  width,
  depth,
  height,
  createNegative = false,
  cutout_height = undef,
  filled_in = true,
  wall_thickness = default_wall_thickness,
  label_settings = LabelSettings(
    labelStyle=default_label_style,
    labelPosition=default_label_position,
    labelSize=default_label_size,
    labelRelief=default_label_relief,
    labelWalls=default_label_walls,
  ),
  finger_slide_settings = FingerSlideSettings(
    type=default_fingerslide,
    radius=default_fingerslide_radius,
    walls=default_fingerslide_walls,
    lip_aligned=default_fingerslide_lip_aligned,
  ),
  cupBase_settings = CupBaseSettings(
    magnetSize=default_magnet_size,
    magnetEasyRelease=default_magnet_easy_release,
    magnetCaptiveHeight=default_magnet_captive_height,
    centerMagnetSize=default_center_magnet_size,
    screwSize=default_screw_size,
    holeOverhangRemedy=default_hole_overhang_remedy,
    cornerAttachmentsOnly=default_box_corner_attachments_only,
    floorThickness=default_floor_thickness,
    cavityFloorRadius=default_cavity_floor_radius,
    efficientFloor=default_efficient_floor,
    halfPitch=default_half_pitch,
    flatBase=default_flat_base,
    spacer=default_spacer,
  ),
  lip_settings = LipSettings(lipStyle=LipStyle_normal, lipNotch=true),
  headroom = default_headroom,
  tapered_corner = default_tapered_corner,
  tapered_corner_size = default_tapered_corner_size,
  tapered_setback = default_tapered_setback,
  wallpattern_walls = default_wallpattern_walls,
  wallpattern_dividers_enabled = default_wallpattern_dividers_enabled,
  wall_pattern_settings = PatternSettings(
    patternEnabled=default_wallpattern_enabled,
    patternStyle=default_wallpattern_style,
    patternRotate=default_wallpattern_rotate_grid,
    patternFill=default_wallpattern_fill,
    patternBorder=default_wallpattern_border,
    patternDepth=default_wallpattern_depth,
    patternCellSize=default_wallpattern_cell_size,
    patternHoleSides=default_wallpattern_hole_sides,
    patternStrength=default_wallpattern_strength,
    patternHoleRadius=default_wallpattern_hole_radius,
    patternGridChamfer=default_wallpattern_pattern_grid_chamfer,
    patternVoronoiNoise=default_wallpattern_pattern_voronoi_noise,
    patternBrickWeight=default_wallpattern_pattern_brick_weight,
    patternFs=default_wallpattern_pattern_quality,
  ),
  floor_pattern_settings = PatternSettings(
    patternEnabled=default_wallpattern_enabled,
    patternStyle=default_wallpattern_style,
    patternRotate=default_wallpattern_rotate_grid,
    patternFill=default_wallpattern_fill,
    patternBorder=default_wallpattern_border,
    patternDepth=default_wallpattern_depth,
    patternCellSize=default_wallpattern_cell_size,
    patternHoleSides=default_wallpattern_hole_sides,
    patternStrength=default_wallpattern_strength,
    patternHoleRadius=default_wallpattern_hole_radius,
    patternGridChamfer=default_wallpattern_pattern_grid_chamfer,
    patternVoronoiNoise=default_wallpattern_pattern_voronoi_noise,
    patternBrickWeight=default_wallpattern_pattern_brick_weight,
    patternFs=default_wallpattern_pattern_quality,
  ),
  wallcutout_vertical_settings = WallCutoutSettings(
    type=default_wallcutout_vertical,
    position=default_wallcutout_vertical_position,
    width=default_wallcutout_vertical_width,
    angle=default_wallcutout_vertical_angle,
    height=default_wallcutout_vertical_height,
    corner_radius=default_wallcutout_vertical_corner_radius,
  ),
  wallcutout_horizontal_settings = WallCutoutSettings(
    type=default_wallcutout_horizontal,
    position=default_wallcutout_horizontal_position,
    width=default_wallcutout_horizontal_width,
    angle=default_wallcutout_horizontal_angle,
    height=default_wallcutout_horizontal_height,
    corner_radius=default_wallcutout_horizontal_corner_radius,
  ),
  extendable_Settings = ExtendableSettings(
    extendablexEnabled=default_extension_x_enabled,
    extendablexPosition=default_extension_x_position,
    extendableyEnabled=default_extension_y_enabled,
    extendableyPosition=default_extension_y_position,
    extendableTabsEnabled=default_extension_tabs_enabled,
    extendableTabSize=default_extension_tab_size,
  ),
  sliding_lid_enabled = default_sliding_lid_enabled,
  sliding_lid_thickness = default_sliding_lid_thickness,
  sliding_lid_lip_enabled = default_sliding_lid_lip_enabled,
  sliding_min_wall_thickness = default_sliding_min_wallThickness,
  sliding_min_support = default_sliding_min_support,
  sliding_clearance = default_sliding_clearance,
  cupBaseTextSettings = CupBaseTextSettings(
    baseTextLine1Enabled=default_text_1,
    baseTextLine2Enabled=default_text_2,
    baseTextLine2Value=default_text_2_text,
    baseTextFontSize=default_text_size,
    baseTextFont=default_text_font,
    baseTextDepth=default_text_depth,
    baseTextOffset=default_text_offset,
  )
) {
  $num_x = width;
  $num_y = depth;
  $num_z = height;
  $num_z_cutout = is_num(cutout_height) ? cutout_height : max(0.5, height - 2);
  module cup() {
    translate(
      [-width * 42 / 2, -depth * 42 / 2, 0],
    )
      gridfinity_cup(
        width,
        depth,
        height,
        filled_in=filled_in,
        wall_thickness=wall_thickness,
        label_settings=label_settings,
        finger_slide_settings=finger_slide_settings,
        cupBase_settings=cupBase_settings,
        lip_settings=lip_settings,
        headroom=headroom,
        tapered_corner=tapered_corner,
        tapered_corner_size=tapered_corner_size,
        tapered_setback=tapered_setback,
        wallpattern_walls=wallpattern_walls,
        wallpattern_dividers_enabled=wallpattern_dividers_enabled,
        wall_pattern_settings=wall_pattern_settings,
        floor_pattern_settings=floor_pattern_settings,
        wallcutout_vertical_settings=wallcutout_vertical_settings,
        wallcutout_horizontal_settings=wallcutout_horizontal_settings,
        extendable_Settings=extendable_Settings,
        sliding_lid_enabled=sliding_lid_enabled,
        sliding_lid_thickness=sliding_lid_thickness,
        sliding_lid_lip_enabled=sliding_lid_lip_enabled,
        sliding_min_wall_thickness=sliding_min_wall_thickness,
        sliding_min_support=sliding_min_support,
        sliding_clearance=sliding_clearance,
        cupBaseTextSettings=cupBaseTextSettings,
      );
  }
  if (createNegative) {
    union() {
      children();
    }
  } else {
    difference() {
      cup();
      children();
    }
  }
}

// Given a set of 2d profiles as children, create cutout for the parent shadowbox.
module cutout(cutoutHeight = undef, chamferSize = undef, eps = 0.1, chamferLayerSize = 0.1) {
  actualCutoutHeight = !is_undef(cutoutHeight) ? cutoutHeight
  : $num_z_cutout;
  actualChamferSize = is_num(chamferSize) ? [chamferSize, chamferSize] : chamferSize;
  echo(actualChamferSize);
  translate([0, 0, 7 * ($num_z - actualCutoutHeight)])
    linear_extrude(7 * actualCutoutHeight)
      children(); if (!is_undef(chamferSize)) {
    translate([0, 0, 7 * $num_z])
      chamferFromOutline(actualChamferSize, layerSize=chamferLayerSize) {
        children();
      }
  }
}
