
//black-grey-white colouring for debugging
void reColour(int[] g) {
  loadPixels();
  for (int i = 0; i < height * width; i++) {
    pixels[i] = color((g[i] < 2 ? 255 * g[i] : 64 * g[i]));
  }
  updatePixels();
}

//Fills pixel[] based on 3 arrays, each for either r,g or b
void falseColor(int[] r, int[] g, int[] b) {
  int cube = 1 << 24; //256^3
  float lrm = 255 / log(amax(r)); 
  float lgm = 255 / log(amax(g));
  float lbm = 255 / log(amax(b)); 
  loadPixels();
  for (int i = 0; i < width * height; i++) {
    pixels[i] = (((int)(log(r[i]) * lrm)) << 16) + (((int)(log(g[i]) * lgm)) << 8) + ((int)(log(b[i]) * lbm)) - cube;
  }
  updatePixels();
}

//Fills pixel[] based on 1 colour array and previous entries to pixel[]
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
    break;
  case "G":
    loadPixels();
    for (int i = 0; i < width * height; i++) {   
      color c = pixels[i];
      pixels[i] = color(c >> 16 & 0xFF, lm * log(map[i]), c & 0xFF);
    }
    updatePixels();
    break;
  case "B":
    loadPixels();
    for (int i = 0; i < width * height; i++) {   
      color c = pixels[i];
      pixels[i] = color(c >> 16 & 0xFF, c >> 8 & 0xFF, lm * log(map[i]));
    }
    updatePixels();
    break;
  }
}

//max value of array
int amax(int[] g) {
  int m = 0;
  for (int i = 0; i < width * height; i++) {
    int a = g[i];
    m = a - ((a-m)&((a-m)>>31));
  }   
  return m;
}
