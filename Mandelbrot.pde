
//Calculate mandelbrot set
void mandelGrid(int Mit) {  
  double minX = centerX - zoomHorizon/2, minY = centerY - zoomVert/2;
  for (int x = -xdim/6; x < 5.0*xdim/6.0; x++) {
    for (int y = 0; y < ydim/2 + 3; y++) {
      double a = minX + (double)x / xdim * zoomHorizon; 
      double b = minY + (double)y / ydim * zoomVert; 

      int it = 0;

      if (!skip(a, b)) {

        Complex c = new Complex(a, b);
        Complex z = new Complex(0, 0);

        while (it < Mit) {
          it++;
          z.Square();
          z.Add(c); 

          if (z.Magnitude() >= 4.0) {
            break;
          }
        }      
        mandelbrot[y + ydim * (x + xdim/6)] = (it < Mit ? false : true);
      } else {
        mandelbrot[y + ydim * (x + xdim/6)] = true;
      }
    }
  }

  for (int x = 0; x < xdim; x++) {
    for (int y = 0; y < ydim/2; y++) {
      mandelbrot[y + ydim/2 + x * ydim] = mandelbrot[ydim/2 - y + x * ydim];
    }
  }
}

//calculates if a point is in the mandelbrot set with cycle check, wip
boolean isInSet(int Mit, Complex c) {
  Complex oldV = new Complex(0, 0);
  Complex v = new Complex(0, 0);
  int stepsTaken = 0;
  int stepLimit = 2;

  for (int it = 0; it < Mit; it++) {
    it++;
    v.Square();
    v.Add(c); 

    if (v.Magnitude() >= 4.0) {
      return false;
    }
    if (v == oldV) {
      return true;
    }
    if (stepsTaken == stepLimit) {
      oldV = v;
      stepsTaken = 0;
      stepLimit *= 2;
    }
    stepsTaken++;
  }
  return true;
}


//skip main circle and cardiod in mandelbrot set
boolean skip(double a, double b) {
  boolean s = false;
  float c = 1.0/4.0;
  a -= 1.0/4.0;
  if (((a + 1.25) * (a + 1.25) + b * b) < 0.0625 || (a*a + b*b) * (a*a + b*b) + 4*c*a*(a*a + b*b) - 4*c*c*b*b < 0 || ((a + 1.558) * (a + 1.558) + b * b) < 0.003 || (a+0.375) * (a+0.375) + (b+0.745) * (b+0.745) < 0.008) {
    s = true;
  }
  return s;
}

//Edge detection, returns array with only the edge left
int[] genBorder(int[] g) {
  int[] temp = new int[ydim * xdim];
  for  (int x = 0; x < xdim; x++) {
    for  (int y = 0; y < xdim; y++) {
      if (x!=0 && y!=0 && x!=xdim-1 && y!=ydim-1) {
        int nbrs = 0;      
        if (g[y + (x + 1) * ydim] == 0) nbrs += 1;
        if (g[y + (x - 1) * ydim] == 0) nbrs += 1;
        if (g[y + 1 + x * ydim] == 0) nbrs += 1;
        if (g[y - 1 + x * ydim] == 0) nbrs += 1;              
        temp[y + x * ydim] = ((nbrs == 4 || nbrs == 0) ? 1 : 0);
      } else {
        temp[y + x * ydim] = 1;
      }
    }
  }
  return temp;
}

void empty() {
  for (int i = 0; i < xdim * ydim; i++) {
    storageGrid[i] = 0;
  }
}


//Random Point Integration, calculate trajectories for set number of random values
void rPI(int Mit, int amount, boolean sym) { //random point iteration
  empty();
  double minX = centerX - zoomHorizon/2, minY = centerY - zoomVert/2;
  int index = 0;
  long itt = 0;

  while (index < amount) {
    double a = (double)random(-2, 2); 
    double b = (double)random(-2, (sym ? 0 : 2));
    int x = (int)((a - minX) / zoomHorizon * xdim) + xdim/6;
    int y = (int)((b - minY) / zoomVert * ydim);
    if (x > 0 && x < xdim && y > 0 && y < ydim) {
      if (!mandelbrot[y + x * ydim]) { //if not in mandelbrotset
        index++;
        Complex c = new Complex(a, b);
        Complex z = new Complex(0, 0);

        int it = 0;
        while (it < Mit) {
          it++;
          z.Square();
          z.Add(c); 

          int y_ = (int)((z.b - minY) / zoomVert * ydim);
          int x_ = (int)((z.a - minX) / zoomHorizon * xdim) + xdim/6;
          if (y_ >= 0 && y_ < ydim && x_ >= 0 && x_ < xdim) {
            storageGrid[y_ + x_ * ydim] += 1;
          }

          itt++;         
          if (z.Magnitude() >= 4.0) {
            break;
          }
        }
      }
    }
  }
  if (sym) {
    for (int x = 0; x < xdim; x++) {
      for (int y = 0; y < ydim/2; y++) {
        storageGrid[y + ydim/2 + x * ydim] = storageGrid[ydim/2 - y + x * ydim];
      }
    }
  }
  println("Avg path: "+((float)itt / (float)index));
}

int[] rPIn(int Mit, int amount, boolean sym) { //random point iteration
  int[] temp = new int[ydim * xdim];
  double minX = centerX - zoomHorizon/2, minY = centerY - zoomVert/2;
  int index = 0;
  long itt = 0;

  while (index < amount) {
    double a = (double)random(-2, 2); 
    double b = (double)random(-2, (sym ? 0 : 2));
    int x = (int)((a - minX) / zoomHorizon * xdim) + xdim/6;
    int y = (int)((b - minY) / zoomVert * ydim);
    if (x > 0 && x < xdim && y > 0 && y < ydim) {
      if (!mandelbrot[y + x * ydim]) { //if not in mandelbrotset
        index++;
        Complex c = new Complex(a, b);
        Complex z = new Complex(0, 0);

        int it = 0;
        while (it < Mit) {
          it++;
          z.Square();
          z.Add(c); 

          int y_ = (int)((z.b - minY) / zoomVert * ydim);
          int x_ = (int)((z.a - minX) / zoomHorizon * xdim) + xdim/6;
          if (y_ >= 0 && y_ < ydim && x_ >= 0 && x_ < xdim) {
            temp[y_ + x_ * ydim] += 1;
          }

          itt++;         
          if (z.Magnitude() >= 4.0) {
            break;
          }
        }
      }
    }
  }
  if (sym) {
    for (int x = 0; x < xdim; x++) {
      for (int y = 0; y < ydim/2; y++) {
        temp[y + ydim/2 + x * ydim] = temp[ydim/2 - y + x * ydim];
      }
    }
  }
  println("Avg path: "+((float)itt / (float)index));
  return temp;
}
