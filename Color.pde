
//black-grey-white colouring for debugging
void reColour() {
  loadPixels();
  for (int i = 0; i < ydim * xdim; i++) {
    pixels[i] = color(mandelbrot[i] ? 255 : 0);
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
  for (int i = 0; i < xdim * ydim; i++) {
    pixels[i] = (((int)(log(r[i]) * lrm)) << 16) + (((int)(log(g[i]) * lgm)) << 8) + ((int)(log(b[i]) * lbm)) - cube;
  }
  updatePixels();
}

//Fills pixel[] based on 1 colour array and previous entries to pixel[]
void falseColor(String Type) {
  float lm = 255 / log(amax(storageGrid));
  loadPixels();
  switch(Type) {
  case "R":    
    for (int i = 0; i < xdim * ydim; i++) {    
      pixels[i] += ((int)(lm * log(storageGrid[i]))) << 16;
    }
    break;
  case "G":
    for (int i = 0; i < xdim * ydim; i++) {   
      pixels[i] += ((int)(lm * log(storageGrid[i]))) << 8;
    }
    break;
  case "B":
    for (int i = 0; i < xdim * ydim; i++) {   
      pixels[i] += (int)(lm * log(storageGrid[i]));
    }    
    break;
  }
  updatePixels();
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
