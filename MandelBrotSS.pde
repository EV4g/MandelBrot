double zoomHorizon;
double zoomVert;
double centerX = 0, centerY = 0;
int Maxit = 50000;
int incr = 20;
int index = 0;
boolean save = false;
int[] grid;
int[] Rg;
int[] Gg;
int[] Bg;

void setup() {
  int start = millis();
  size(5000, 5000);
  
  grid = new int [height * width];
  Rg = new int[height * width];
  Gg = new int[height * width];
  Bg = new int[height * width];
   
  zoomHorizon = 3.0;
  zoomVert = 3.0/((double)width/(double)height);
  
  grid = mandelGrid(5000, grid, true);  
  
  int mset = millis()-start;
  println("Checked points: "+mset+"ms");
        
  Rg = rPI(5000, 1*(int)pow(10, 7), grid); //8 --> good image, 5 * 10^8 for 20k
  Gg = rPI(500, 1*(int)pow(10, 7), grid); //5* 
  Bg = rPI(50, 1*(int)pow(10, 7), grid); //15*
  
  //falseColor(rPI(5000, 1*(int)pow(10, 7), grid), "R");
  //falseColor(rPI(500, 1*(int)pow(10, 7), grid), "G");
  //falseColor(rPI(50, 1*(int)pow(10, 7), grid), "B");
   
  //reColour(grid); //display mandelbrot set for debug
  
  int Calc = millis() - start - mset;
  println("Calculated trajectories: "+Calc+"ms");
  
  falseColor(Rg, Gg, Bg); 
  
  int Color = millis() - start - (Calc + mset);
  println("Calculated colour: "+Color+"ms");
  
  //save(str(width)+"x"+str(height)+"x"+str(incr)+".png"); 
  //println("Saved: "+(millis() - (Calc + mset + Color) - start)+"ms");
  println("Total: "+(millis() - start)+"ms");  
}

void keyPressed(){
  if(key == 's'){
    save(str(width)+"x"+str(height)+"x"+str(incr)+".png");
    println("saved");
  }
  if(key == 'r'){
    save = !save;
    println("save: "+save);
  }
}

void draw() { 
  noLoop();
}
