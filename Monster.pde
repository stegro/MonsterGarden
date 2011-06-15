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


class AbstractMonster
{
 String name;
 String author;
 String id;
 long ean;
 
 int level;
 
 
 AbstractMonster(long ean, String id)
 {
   this.ean = ean;
   this.id = id;
   setLevels();
 }
 
 void display(){
   
 }

 void setLevels() {
   //Laplace distribution
   double my = 0; //center
   double b = 1.3; //scaling
   level = (int)(my - b * log(1.0 - 2.0 * abs(random(1)-0.5)));
 }
 
 void displayData(PFont font) {
  stroke(0);
  fill(255,255,255,70);
  rect(0.5*(width-400), height-82, 400, 80);
  //specify color
  fill(0);
  textAlign(CENTER);
  textFont(font,36);
  text(name, width*0.5, height-50);   
  textFont(font,18);
  text("Level " + level, width*0.5, height-30);
  text("First sighted by " + author, width*0.5, height-8);
  }
}
