
void reColour(int[][] g) {
  float gamma = 1;
  int m = amax(g);
  float sqm = sqrt(m);
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      //set(y, x, color(255 * log(g[y][x]) / log(m)));
      //set(x, y, color(255 * pow(g[x][y] / m, 1.0/gamma))); 
      //set(x, y, color(2 * g[x][y]));
      set(x, y, color((g[x][y] < 2 ? 255 * g[x][y] : 64 * g[x][y])));
    }
  }
}

//1D array version
void reColour(int[] g) {
  loadPixels();
  for (int i = 0; i < height * width; i++) {
    pixels[i] = color((g[i] < 2 ? 255 * g[i] : 64 * g[i]));
  }
  updatePixels();
}

void falseColor(int[][] r, int[][] g, int[][] b) {
  float lbm = 255 / log(amax(b)); 
  float lrm = 255 / log(amax(r)); 
  float lgm = 255 / log(amax(g)); 
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      pixels[x + y * width] =  color(log(r[x][y]) * lrm, log(g[x][y]) * lgm, log(b[x][y]) * lbm);
      //set(x, y, color(log(r[x][y]) * lrm, log(g[x][y]) * lgm, log(b[x][y]) * lbm)); //log
    }
  }
  updatePixels();
}

void falseColor(int[] r, int[] g, int[] b) {
  float lbm = 255 / log(amax(b)); 
  float lrm = 255 / log(amax(r)); 
  float lgm = 255 / log(amax(g)); 
  loadPixels();
  for (int i = 0; i < width * height; i++) {
    pixels[i] =  color(log(r[i]) * lrm, log(g[i]) * lgm, log(b[i]) * lbm);
  }
  updatePixels();
}

void falseColor(int[][] map, String Type) {
  float lm = 255 / log(amax(map)); 

  switch(Type) {
  case "R":
    loadPixels();
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        int index = x + y * width;      
        color c = pixels[index];
        pixels[index] = color(lm * log(map[x][y]), c >> 8 & 0xFF, c & 0xFF);
      }
    }
    updatePixels();
  case "G":
    loadPixels();
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        int index = x + y * width;      
        color c = pixels[index];
        pixels[index] = color(c >> 16 & 0xFF, lm * log(map[x][y]), c & 0xFF);
      }
    }
    updatePixels();
  case "B":
    loadPixels();
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        int index = x + y * width;      
        color c = pixels[index];
        pixels[index] = color(c >> 16 & 0xFF, c >> 8 & 0xFF, lm * log(map[x][y]));
      }
    }
    updatePixels();
  }
}

void falseColor(int[] map, String Type) {
  float lm = 255 / log(amax(map)); 
  switch(Type) {
  case "R":
    loadPixels();
    for (int i = 0; i < width * height; i++) {    
      color c = pixels[i];
      pixels[i] = color(lm * log(map[i]), c >> 8 & 0xFF, c & 0xFF);
    }
    updatePixels();
  case "G":
    loadPixels();
    for (int i = 0; i < width * height; i++) {   
      color c = pixels[i];
      pixels[i] = color(c >> 16 & 0xFF, lm * log(map[i]), c & 0xFF);
    }
    updatePixels();
  case "B":
    loadPixels();
    for (int i = 0; i < width * height; i++) {   
      color c = pixels[i];
      pixels[i] = color(c >> 16 & 0xFF, c >> 8 & 0xFF, lm * log(map[i]));
    }
    updatePixels();
  }
}

int amax(int[][] g) {
  int m = 0;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int a = g[y][x];
      m = a - ((a-m)&((a-m)>>31));
    }
  }   
  return m;
}

int amax(int[] g) {
  int m = 0;
  for (int i = 0; i < width * height; i++) {
    int a = g[i];
    m = a - ((a-m)&((a-m)>>31));
  }   
  return m;
}
