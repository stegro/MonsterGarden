/*
    Monster Garden - a simple and open source barcode scanning game
    Copyright (C) 2011  Stefan Großhauser

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


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
