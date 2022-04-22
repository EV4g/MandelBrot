
//Calculate mandelbrot set
void mandelGrid(int Mit) {
  double zd = zoom / rdim;
  for (int x = -rdim/6; x < 5.0*rdim/6.0; x++) {
    for (int y = 0; y < rdim/2 + 3; y++) {
      double a = minX + (double)x * zd; 
      double b = minY + (double)y * zd;  
      mandelbrot[y + rdim * (x + rdim/6)] = inMandel(a, b, Mit);
    }
  }

  //symmetry part
  for (int x = 0; x < rdim; x++) {
    for (int y = 0; y < rdim/2; y++) {
      mandelbrot[y + rdim/2 + x * rdim] = mandelbrot[rdim/2 - y + x * rdim];
    }
  }
}

//Calculate mandelbrot set for a, b
boolean inMandel(double a, double b, int Mit) {    
  int it = 0;
  if (!skip(a, b)) {
    Complex c = new Complex(a, b);
    Complex z = new Complex(0, 0);
    while (it < Mit) {
      it++;
      z.Square();
      z.Add(c); 
      if (z.Magnitude() > 4.0) {
        break;
      }
    }      
    return (it < Mit ? false : true);
  } else {
    return true;
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

    if (v.Magnitude() > 4.0) {
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
  float c = 1.0/4.0;
  a -= 1.0/4.0;
  if (((a + 1.25) * (a + 1.25) + b * b) < 0.0625 || (a*a + b*b) * (a*a + b*b) + 4*c*a*(a*a + b*b) - 4*c*c*b*b < 0 || ((a + 1.558) * (a + 1.558) + b * b) < 0.003 || (a+0.375) * (a+0.375) + (b+0.745) * (b+0.745) < 0.008) {
    return true;
  }
  return false;
}

//Edge detection, returns array with only the edge left
boolean[] genBorder() {
  boolean[] temp = new boolean[rdim * rdim];
  for  (int x = 0; x < rdim; x++) {
    for  (int y = 0; y < rdim; y++) {
      if (x!=0 && y!=0 && x!=rdim-1 && y!=rdim-1) {
        int nbrs = 0;      
        if (!mandelbrot[y + (x + 1) * rdim]) nbrs += 1;
        if (!mandelbrot[y + (x - 1) * rdim]) nbrs += 1;
        if (!mandelbrot[(y + 1) + x * rdim]) nbrs += 1;
        if (!mandelbrot[(y - 1) + x * rdim]) nbrs += 1;              
        temp[y + x * rdim] = ((nbrs == 4 || nbrs == 0) ? true : false);
      } else {
        temp[y + x * rdim] = true;
      }
    }
  }
  return temp;
}

void empty() {
  for (int i = 0; i < rdim * rdim; i++) {
    storageGrid[i] = 0;
  }
}

//Random Point Iteration, calculate trajectories for a set number of random values
void rPI(int Mit, int amount) {
  empty();  
  int index = 0;
  long itt = 0;  
  double dz = rdim / zoom;
  int sdim = rdim/6;
  while (index < amount) {
    double a = (double)random(-2, 2); 
    double b = (double)random(-2, 2);
    int x = (int)((a - minX) * dz) + sdim;
    int y = (int)((b - minY) * dz);
    if (x > 0 && x < rdim && y > 0 && y < rdim) {
      if (!mandelbrot[y + x * rdim]) { //if not in mandelbrotset
        index++;
        Complex c = new Complex(a, b);
        Complex z = new Complex(0, 0);

        int it = 0;
        while (it < Mit) {
          it++;
          z.Square();
          z.Add(c); 

          int y_ = (int)((z.b - minY) * dz);
          int x_ = (int)((z.a - minX) * dz) + sdim;
          if (y_ >= 0 && y_ < rdim && x_ >= 0 && x_ < rdim) {
            storageGrid[y_ + x_ * rdim] += 1;
          }

          itt++;         
          if (z.Magnitude() >= 4.0) {
            break;
          }
        }
      }
    }
  }
  println("Avg path: "+((float)itt / (float)index));
}

//Random Point Iteration with array-return
int[] rPIn(int Mit, int amount, boolean sym) {
  int[] temp = new int[rdim * rdim];
  int index = 0;
  long itt = 0;
  
  double dz = rdim / zoom;
  while (index < amount) {
    double a = (double)random(-2, 2); 
    double b = (double)random(-2, (sym ? 0 : 2));
    int x = (int)((a - minX) * dz) + rdim/6; //initial coords
    int y = (int)((b - minY) * dz);
    if (x > 0 && x < rdim && y > 0 && y < rdim) {
      if (!mandelbrot[y + x * rdim]) { //if not in mandelbrotset
        index++;
        Complex c = new Complex(a, b);
        Complex z = new Complex(0, 0);

        int it = 0;
        while (it < Mit) {
          it++;
          z.Square();
          z.Add(c); 

          int y_ = (int)((z.b - minY) * dz); //coords for storagegrids
          int x_ = (int)((z.a - minX) * dz) + rdim/6;
          if (y_ >= 0 && y_ < rdim && x_ >= 0 && x_ < rdim) {
            temp[y_ + x_ * rdim] += 1;
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
    for (int x = 0; x < rdim; x++) {
      for (int y = 0; y < rdim/2; y++) {
        temp[rdim/2 - y + x * rdim] += temp[y + rdim/2 + x * rdim];
        temp[y + rdim/2 + x * rdim] = temp[rdim/2 - y + x * rdim];
      }
    }
  }
  println("Avg path: "+((float)itt / (float)index));
  return temp;
}

//Random Point Iteration without mandelbrot-lookup-array
void rPI2(int Mit, int amount) {
  empty();
  int index = 0;
  long itt = 0;
  
  double dz = rdim / zoom;
  while (index < amount) {
    double a = (double)random(-2, 2); 
    double b = (double)random(-2, 2);
    if (!inMandel(a, b, mandelmax)) { //if not in mandelbrotset
      index++;
      Complex c = new Complex(a, b);
      Complex z = new Complex(0, 0);

      int it = 0;
      while (it < Mit) {
        it++;
        z.Square();
        z.Add(c); 

        int y_ = (int)((z.b - minY) * dz);
        int x_ = (int)((z.a - minX) * dz) + rdim/6;
        if (y_ >= 0 && y_ < rdim && x_ >= 0 && x_ < rdim) {
          storageGrid[y_ + x_ * rdim] += 1;
        }

        itt++;         
        if (z.Magnitude() >= 4.0) {
          break;
        }
      }
    }
  }
  println("Avg path: "+((float)itt / (float)index));
}

//Random Point Iteration with array-return
int[] rPIn2(int Mit, int amount, boolean sym) {
  int[] temp = new int[rdim * rdim];
  int index = 0;
  long itt = 0;
  
  double dz = rdim / zoom;
  while (index < amount) {
    double a = (double)random(-2, 2); 
    double b = (double)random(-2, (sym ? 0 : 2));
    if (!inMandel(a, b, mandelmax)) { //if not in mandelbrotset
      index++;
      Complex c = new Complex(a, b);
      Complex z = new Complex(0, 0);

      int it = 0;
      while (it < Mit) {
        it++;
        z.Square();
        z.Add(c); 

        int y_ = (int)((z.b - minY) * dz); //coords for storagegrids
        int x_ = (int)((z.a - minX) * dz) + rdim/6;
        if (y_ >= 0 && y_ < rdim && x_ >= 0 && x_ < rdim) {
          temp[y_ + x_ * rdim] += 1;
        }

        itt++;         
        if (z.Magnitude() >= 4.0) {
          break;
        }
      }
    }
  }
  if (sym) {
    for (int x = 0; x < rdim; x++) {
      for (int y = 0; y < rdim/2; y++) {
        temp[rdim/2 - y + x * rdim] += temp[y + rdim/2 + x * rdim];
        temp[y + rdim/2 + x * rdim] = temp[rdim/2 - y + x * rdim];
      }
    }
  }
  println("Avg path: "+((float)itt / (float)index));
  return temp;
}


//averages a square of pixels down to one
void downscaler() {
  if (rdim > odim) {
    for (int x = 0; x < odim; x++) {
      for (int y = 0; y < odim; y++) {
        int sum = 0;
        for (int i = 0; i < fac; i++) {
          for (int j = 0; j < fac; j++) {
            if ((y+j) + (x+i) * odim < odim * odim) {
              sum += storageGrid[(y * fac + j) + (x * fac + i) * rdim];
            }
          }
        }
        storageGrid[y + x * odim] = sum / (fac * fac);
      }
    }
  }
}
