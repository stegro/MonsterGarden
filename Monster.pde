class AbstractMonster
{
 String name;
 String author;
 long ean;
 
 int level;
 
 
 AbstractMonster(long ean)
 {
   this.ean = ean;
   setLevels();
 }
 
 void display(){
   
 }

 void setLevels() {
   level = (int)random(11);
 }
 
 void displayData() {
  PFont f;
  f = loadFont("FreeSerif-48.vlw");  
  stroke(0);
  fill(255,255,255,70);
  rect(0.5*(width-400), height-82, 400, 80);
  //specify color
  fill(0);
  textAlign(CENTER);
  textFont(f,36);
  text(name, width*0.5, height-50);   
  textFont(f,18);
  text("Level " + level, width*0.5, height-30);
  text("First sighted by " + author, width*0.5, height-8);
  }
}
