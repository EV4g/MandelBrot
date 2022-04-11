
//complex number support
class Complex {
  double a; //real 
  double b; //imag
  
  Complex(double a, double b){
    this.a = a;
    this.b = b;
  }
  
  void Square(){
    double temp = a * a - b * b;
    b = 2.0 * a * b;
    a = temp;
  }
  
  void AbsSquare(){
    double temp = a * a - b * b;
    a = (a > 0 ? a : -a);
    b = (b > 0 ? b : -b);
    b = 2.0 * a * b;
    a = temp;    
  }
  
  double Magnitude(){
    return a * a + b * b;
  }
  
  void Add(Complex c){
    a+= c.a;
    b+= c.b;
  }
  
  void DivBy(Complex u){
    double temp = (a * u.a + b * u.b) / (u.a * u.a + u.b * u.b);
    b = (b * u.a - a * u.b) / (u.a * u.a + u.b * u.b);
    a = temp; 
  }
  
  void Div(float c){
    a /= c;
    b /= c;
  }  
}
