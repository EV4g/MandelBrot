
//black-grey-white colouring for debugging
void reColour(boolean[] arr) {
  img.loadPixels();
  for (int i = 0; i < rdim * rdim; i++) {
    img.pixels[i] = color(arr[i] ? 255 : 0);
  }
  img.updatePixels();
}

//Fills pixel[] based on 3 arrays, each for either r,g or b
void falseColor() {
  int cube = 1 << 24; //256^3
  float lrm = 255 / log(amax(Rg)); 
  float lgm = 255 / log(amax(Gg));
  float lbm = 255 / log(amax(Bg)); 
  img.loadPixels();
  for (int i = 0; i < odim * odim; i++) {
    img.pixels[i] = (((int)(log(Rg[i]) * lrm)) << 16) + (((int)(log(Gg[i]) * lgm)) << 8) + ((int)(log(Bg[i]) * lbm)) - cube;
  }
  img.updatePixels();
}

//Fills pixel[] based on 1 colour array and previous entries to pixel[]
void falseColor(int offset) {
  downscaler();
  float lm = 255 / log(imamax());
  img.loadPixels();
  for (int x = 0; x < odim; x++) {    
    for (int y = 0; y < odim; y++) {    
      img.pixels[y * odim + x] += ((int)(lm * log(storageGrid[y * odim + x]))) << offset;
    }
  }
  img.updatePixels();
}

//max value of array
int amax(int[] g) {
  int m = 0;
  for (int i = 0; i < rdim * rdim; i++) {
    int a = g[i];
    m = a - ((a-m)&((a-m)>>31));
  }
  return m;
}

//max value of storageGrid
int imamax() {
  int m = 0;
  for (int i = 0; i < rdim * rdim; i++) {
    int a = storageGrid[i];
    m = a - ((a-m)&((a-m)>>31));
  }
  return m;
}

void init() {
  for (int i = 0; i < odim * odim; i++) {
    img.pixels[i]  = -1 << 24;
  }
}
