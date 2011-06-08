class MoMoMonster extends AbstractMonster
{
  String moMoDatabase = "moMoMonsters.txt";
  PImage img;
  
 MoMoMonster(long ean)
 {
   super(ean);
   randomSpeciesFromDatabase();
 }
  
 void display(){
  image(img, 0.5 * (width - img.width), 0.5 * (height - img.height));
 } 
 
 void randomSpeciesFromDatabase() {
    try{
      String[] lines = loadStrings(moMoDatabase);
      int choice = int(random(0, lines.length));
      // Line Format:
      // <imagefile>;<Monster trivial name>;<author>
      String[] pieces = splitTokens(lines[choice], "\t;");
      
      this.img = loadImage(pieces[0]);
      this.name = pieces[1];
      this.author = pieces[2];
      
      
    }catch(Exception ex){
      println("Could not read " + moMoDatabase +", "+ex.toString());
    }
  }


}
