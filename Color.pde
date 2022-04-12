
//black-grey-white colouring for debugging
void reColour() {
  img.loadPixels();
  for (int i = 0; i < ydim * xdim; i++) {
    img.pixels[i] = color(mandelbrot[i] ? 255 : 0);
  }
  img.updatePixels();
}

//Fills pixel[] based on 3 arrays, each for either r,g or b
void falseColor(int[] r, int[] g, int[] b) {
  int cube = 1 << 24; //256^3
  float lrm = 255 / log(amax(r)); 
  float lgm = 255 / log(amax(g));
  float lbm = 255 / log(amax(b)); 
  img.loadPixels();
  for (int i = 0; i < xdim * ydim; i++) {
    img.pixels[i] = (((int)(log(r[i]) * lrm)) << 16) + (((int)(log(g[i]) * lgm)) << 8) + ((int)(log(b[i]) * lbm)) - cube;
  }
  img.updatePixels();
}

//Fills pixel[] based on 1 colour array and previous entries to pixel[]
void falseColor(int offset) {
  float lm = 255 / log(imamax());
  img.loadPixels();
  for (int i = 0; i < xdim * ydim; i++) {    
    img.pixels[i] += ((int)(lm * log(storageGrid[i]))) << offset;
  }
  img.updatePixels();
}

//max value of array
int amax(int[] g) {
  int m = 0;
  for (int i = 0; i < xdim * ydim; i++) {
    int a = g[i];
    m = a - ((a-m)&((a-m)>>31));
  }
  return m;
}

//max value of storageGrid
int imamax() {
  int m = 0;
  for (int i = 0; i < xdim * ydim; i++) {
    int a = storageGrid[i];
    m = a - ((a-m)&((a-m)>>31));
  }
  return m;
}

void init() {
  for (int i = 0; i < xdim * ydim; i++) {
    img.pixels[i]  = -1 << 24;
  }
}
