
//Calculate mandelbrot set
void mandelGrid(int Mit) {  
  double minX = centerX - zoom/2, minY = centerY - zoom/2;
  for (int x = -dim/6; x < 5.0*dim/6.0; x++) {
    for (int y = 0; y < dim/2 + 3; y++) {
      double a = minX + (double)x / dim * zoom; 
      double b = minY + (double)y / dim * zoom;  
      mandelbrot[y + dim * (x + dim/6)] = inMandel(a, b, Mit);
    }
  }
  
  //symmetry part
  for (int x = 0; x < dim; x++) {
    for (int y = 0; y < dim/2; y++) {
      mandelbrot[y + dim/2 + x * dim] = mandelbrot[dim/2 - y + x * dim];
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
      if (z.Magnitude() >= 4.0) {
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
  int[] temp = new int[dim * dim];
  for  (int x = 0; x < dim; x++) {
    for  (int y = 0; y < dim; y++) {
      if (x!=0 && y!=0 && x!=dim-1 && y!=dim-1) {
        int nbrs = 0;      
        if (g[y + (x + 1) * dim] == 0) nbrs += 1;
        if (g[y + (x - 1) * dim] == 0) nbrs += 1;
        if (g[y + 1 + x * dim] == 0) nbrs += 1;
        if (g[y - 1 + x * dim] == 0) nbrs += 1;              
        temp[y + x * dim] = ((nbrs == 4 || nbrs == 0) ? 1 : 0);
      } else {
        temp[y + x * dim] = 1;
      }
    }
  }
  return temp;
}

void empty() {
  for (int i = 0; i < dim * dim; i++) {
    storageGrid[i] = 0;
  }
}

//Random Point Iteration, calculate trajectories for a set number of random values
void rPI(int Mit, int amount, boolean sym) {
  empty();
  double minX = centerX - zoom/2, minY = centerY - zoom/2;
  int index = 0;
  long itt = 0;

  while (index < amount) {
    double a = (double)random(-2, 2); 
    double b = (double)random(-2, (sym ? 0 : 2));
    int x = (int)((a - minX) / zoom * dim) + dim/6;
    int y = (int)((b - minY) / zoom * dim);
    if (x > 0 && x < dim && y > 0 && y < dim) {
      if (!mandelbrot[y + x * dim]) { //if not in mandelbrotset
        index++;
        Complex c = new Complex(a, b);
        Complex z = new Complex(0, 0);

        int it = 0;
        while (it < Mit) {
          it++;
          z.Square();
          z.Add(c); 

          int y_ = (int)((z.b - minY) / zoom * dim);
          int x_ = (int)((z.a - minX) / zoom * dim) + dim/6;
          if (y_ >= 0 && y_ < dim && x_ >= 0 && x_ < dim) {
            storageGrid[y_ + x_ * dim] += 1;
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
    for (int x = 0; x < dim; x++) {
      for (int y = 0; y < dim/2; y++) {
        storageGrid[dim/2 - y + x * dim] += storageGrid[y + dim/2 + x * dim];
        storageGrid[y + dim/2 + x * dim] = storageGrid[dim/2 - y + x * dim];
      }
    }
  }
  println("Avg path: "+((float)itt / (float)index));
}

//Random Point Iteration with array-return
int[] rPIn(int Mit, int amount, boolean sym) {
  int[] temp = new int[dim * dim];
  double minX = centerX - zoom/2, minY = centerY - zoom/2;
  int index = 0;
  long itt = 0;

  while (index < amount) {
    double a = (double)random(-2, 2); 
    double b = (double)random(-2, (sym ? 0 : 2));
    int x = (int)((a - minX) / zoom * dim) + dim/6; //initial coords
    int y = (int)((b - minY) / zoom * dim);
    if (x > 0 && x < dim && y > 0 && y < dim) {
      if (!mandelbrot[y + x * dim]) { //if not in mandelbrotset
        index++;
        Complex c = new Complex(a, b);
        Complex z = new Complex(0, 0);

        int it = 0;
        while (it < Mit) {
          it++;
          z.Square();
          z.Add(c); 

          int y_ = (int)((z.b - minY) / zoom * dim); //coords for storagegrids
          int x_ = (int)((z.a - minX) / zoom * dim) + dim/6;
          if (y_ >= 0 && y_ < dim && x_ >= 0 && x_ < dim) {
            temp[y_ + x_ * dim] += 1;
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
    for (int x = 0; x < dim; x++) {
      for (int y = 0; y < dim/2; y++) {
        temp[dim/2 - y + x * dim] += temp[y + dim/2 + x * dim];
        temp[y + dim/2 + x * dim] = temp[dim/2 - y + x * dim];
      }
    }
  }
  println("Avg path: "+((float)itt / (float)index));
  return temp;
}

//Random Point Iteration without mandelbrot-lookup-array
void rPI2(int Mit, int amount, boolean sym) {
  empty();
  double minX = centerX - zoom/2, minY = centerY - zoom/2;
  int index = 0;
  long itt = 0;

  while (index < amount) {
    double a = (double)random(-2, 2); 
    double b = (double)random(-2, (sym ? 0 : 2));
    int x = (int)((a - minX) / zoom * dim) + dim/6;
    int y = (int)((b - minY) / zoom * dim);
    if (x > 0 && x < dim && y > 0 && y < dim) {
      if (!inMandel(a, b, 5000)) { //if not in mandelbrotset
        index++;
        Complex c = new Complex(a, b);
        Complex z = new Complex(0, 0);

        int it = 0;
        while (it < Mit) {
          it++;
          z.Square();
          z.Add(c); 

          int y_ = (int)((z.b - minY) / zoom * dim);
          int x_ = (int)((z.a - minX) / zoom * dim) + dim/6;
          if (y_ >= 0 && y_ < dim && x_ >= 0 && x_ < dim) {
            storageGrid[y_ + x_ * dim] += 1;
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
    for (int x = 0; x < dim; x++) {
      for (int y = 0; y < dim/2; y++) {
        storageGrid[dim/2 - y + x * dim] += storageGrid[y + dim/2 + x * dim];
        storageGrid[y + dim/2 + x * dim] = storageGrid[dim/2 - y + x * dim];
      }
    }
  }
  println("Avg path: "+((float)itt / (float)index));
}

void downscaler(){
  //plain averaging
  //shifted gaussian weights averaging
  
}
