
int[] mandelGrid(int Mit, int[] g, boolean sym) {
  int ymax = (sym ? height / 2 + 2 : height);   
  double minX = centerX - zoomHorizon/2, minY = centerY - zoomVert/2;
  for (int x = -width/6; x < 5.0*width/6.0; x++) {
    for (int y = 0; y < ymax; y++) {
      double a = minX + (double)x / width * zoomHorizon; 
      double b = minY + (double)y / height * zoomVert; 

      int it = 0;

      if (!skip(a, b) || !sym) {

        Complex c = new Complex(a, b);
        Complex z = new Complex(0, 0);

        while (it < Mit) {
          it++;
          z.Square();
          z.Add(c); 

          if (z.Magnitude() >= 4.0)           
            break;
        }
        g[y + height * (x + width/6)] = (it < Mit ? 1 : 0);
      } else {
        g[y + height * (x + width/6)] = 0;
      }
    }
  }

  if (sym) {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height/2; y++) {
        g[y + height/2 + x * height] = g[height/2 - y + x * height];
      }
    }
  }
  return g;
}

//skip main circle and cardiod in mandelbrot set
boolean skip(double a, double b) {
  boolean s = false;
  float c = 1.0/4.0;
  a -= 1.0/4.0;
  if (((a + 1.25) * (a + 1.25) + b * b) < 0.0625 || (a*a + b*b) * (a*a + b*b) + 4*c*a*(a*a + b*b) - 4*c*c*b*b < 0) {
    s = true;
  }
  return s;
}

int[] genBorder(int[] g) {
  int[] temp = new int[height * width];
  for  (int x = 0; x < width; x++) {
    for  (int y = 0; y < width; y++) {
      if (x!=0 && y!=0 && x!=width-1 && y!=height-1) {
        int nbrs = 0;      
        if (g[y + (x + 1) * height] == 0) nbrs += 1;
        if (g[y + (x - 1) * height] == 0) nbrs += 1;
        if (g[y + 1 + x * height] == 0) nbrs += 1;
        if (g[y - 1 + x * height] == 0) nbrs += 1;              
        temp[y + x * height] = ((nbrs == 4 || nbrs == 0) ? 1 : 0);
      } else {
        temp[y + x * height] = 1;
      }
    }
  }
  return temp;
}

int[] rPI(int Mit, int amount, int[] selection, boolean sym) { //random point iteration
  int[] temp = new int[height * width];
  double minX = centerX - zoomHorizon/2, minY = centerY - zoomVert/2;
  int index = 0;
  
  long itt = 0;
  
  while (index < amount) {
    double a = (double)random(-2, 2); 
    double b = (double)random(-2, (sym ? 0 : 2));
    int x = (int)((a - minX) / zoomHorizon * width) + width/6;
    int y = (int)((b - minY) / zoomVert * height);
    if (x > 0 && x < width && y > 0 && y < height) {
      if (selection[y + x * height] != 0) { // == 0 for border, != 0 for all outside of set
        index++;
        Complex c = new Complex(a, b);
        Complex z = new Complex(0, 0);

        int it = 0;

        while (it < Mit) {
          it++;
          z.Square();
          z.Add(c); 

          int y_ = (int)((z.b - minY) / zoomVert * height);
          int x_ = (int)((z.a - minX) / zoomHorizon * width) + width/6;
          if (y_ >= 0 && y_ < height && x_ >= 0 && x_ < width) {
            temp[y_ + x_ * height] += 1;
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
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height/2; y++) {
        temp[y + height/2 + x * height] = temp[height/2 - y + x * height];
      }
    }
  }
  println("Avg path: "+((float)itt / (float)index));
  return temp;
}
