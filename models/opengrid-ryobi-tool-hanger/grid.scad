module gridify(w, h, key, lite = false) {
  assert(len(key) == h);
  for (row = key) {
    assert(len(row) == w);
  }
  translate([(w - 0.5) * 28, (h - 0.5) * 28, -(lite ? 4 : 6.8) / 2])
    rotate([0, 0, 180])for (i = [0:len(key) - 1])
      for (j = [0:len(key[i]) - 1])
        if (key[i][j])
          translate([j * 28, i * 28, 0]) children();
}
