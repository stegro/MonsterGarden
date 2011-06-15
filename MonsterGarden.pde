/*
    Monster Garden - a small open source barcode scanning game
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


import controlP5.*;
import processing.video.*;

import com.google.zxing.*;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.common.*;
import com.google.zxing.oned.*;


import java.awt.image.*;
import java.awt.Graphics2D;

import codeanticode.gsvideo.*;

String saveFile = "monsterBook.txt";

int HOVER_GRAY = 100;

int mode;
int CATCH = 1;
int NOTHING = 0;
int GARDEN = 2;

//operating system
String os;

//GSVideo
GSCapture cam;

//ControlP5
ControlP5 controlP5;
Button previous, next, free;
Knob knob;

// standard Quicktime video lib
Capture video;

// Monster garden
ArrayList monsterList;
int gardenIterator;
AbstractMonster gardenExemplum;

void setup() {
  size(640,480);
  frameRate(10);
  os = System.getProperty("os.name").toLowerCase();
  println("Your operating system is "+os);
  
  monsterList = new ArrayList();
  loadGarden(monsterList);
  gardenIterator = 0;
  updateGarden();

  if(os.equals("linux")) {
    cam = new GSCapture(this, 640, 480);
  }else{
    video = new Capture(this, width, height, 25);
  }
 
 
  
  controlP5 = new ControlP5(this);
  
  controlP5.begin(5,5);
  Button b;
  
  
  b = controlP5.addButton("catch",0,5,5,100,14);
  b.setLabel("catch a creature");
  b.setColorBackground(color(0,0,0));
  b.setColorForeground(color(HOVER_GRAY,HOVER_GRAY,HOVER_GRAY));
  b.setColorActive(color(255,255,255));
  
  b = controlP5.addButton("garden",0,5,20,100,14);
  b.setLabel("garden");
  b.setColorBackground(color(0,0,0));
  b.setColorForeground(color(HOVER_GRAY,HOVER_GRAY,HOVER_GRAY));
  b.setColorActive(color(255,255,255));
  
  previous = controlP5.addButton("previous",0,20,35,49,14);
  previous.setLabel("<");
  previous.setColorBackground(color(0,0,0));
  previous.setColorForeground(color(HOVER_GRAY,HOVER_GRAY,HOVER_GRAY));
  previous.setColorActive(color(255,255,255));
  previous.hide();


  next = controlP5.addButton("next",0,70,35,49,14);
  next.setLabel(">");
  next.setColorBackground(color(0,0,0));
  next.setColorForeground(color(HOVER_GRAY,HOVER_GRAY,HOVER_GRAY));
  next.setColorActive(color(255,255,255));
  next.hide();
  
  free = controlP5.addButton("free",0, 120,35,100,14);
  free.setLabel("free this creature");
  free.setColorBackground(color(100,0,0));
  free.setColorForeground(color(200,HOVER_GRAY,HOVER_GRAY));
  free.setColorActive(color(255,255,255));
  free.hide();

  knob = controlP5.addKnob("knob",0,monsterList.size(),50,50,40);
  knob.setResolution(1.0);
  knob.setRange(2*PI);
  knob.setValue(gardenIterator);
  knob.setNumberOfTickMarks(0);
//  knob.snapToTickMarks(true);
  knob.setColorBackground(color(0,0,0));
  knob.setColorForeground(color(HOVER_GRAY,HOVER_GRAY,HOVER_GRAY));
  knob.setColorActive(color(HOVER_GRAY,HOVER_GRAY,HOVER_GRAY));
  knob.hide();
    
/*  MultiListButton cc = (MultiListButton)controlP5.controller("menu");
  cc.setHeight(40);
  */
    controlP5.end();
}





void controlEvent(ControlEvent theEvent) 
{
//  println(theEvent.controller().name()+" = "+theEvent.value());  

  if(!theEvent.controller().name().equals("catch")){
    if(os.equals("linux"))
      cam.pause();
    else
      video.stop();
  }
  if(theEvent.controller().name().equals("catch"))
  {
    mode = CATCH;
    if(os.equals("linux")) {
      if(!cam.isPlaying())
        cam.play(); 
      if(!cam.available() == true){
        println("Webcam not available " + cam.toString());
        return;
      }
      cam.read();
    }else{
      if(!video.available()){
        println("Video not available " + cam.toString());
        return;
      }
      video.read(); // Read the new frame from the camera
      video.loadPixels();
    }


    
      Hashtable<DecodeHintType, Object> hints = new Hashtable<DecodeHintType, Object>();
        hints.put(DecodeHintType.TRY_HARDER, Boolean.TRUE);
      Vector<BarcodeFormat> formats = new Vector<BarcodeFormat>();
      formats.add(BarcodeFormat.EAN_8);
      formats.add(BarcodeFormat.EAN_13);
      hints.put(DecodeHintType.POSSIBLE_FORMATS,formats);
      com.google.zxing.Reader reader = new MultiFormatUPCEANReader(hints);

      BufferedImage myImage = new BufferedImage(640, 480, BufferedImage.TYPE_INT_ARGB_PRE  );
      Graphics2D g2d = myImage.createGraphics();
  //  g2d.drawImage((java.awt.Image)cam, 0, 0, w, w, this);
      if(os.equals("linux"))
        g2d.drawImage((java.awt.Image)cam.getImage(), 0, 0, 640, 480, this);
      else
        g2d.drawImage((java.awt.Image)video.getImage(), 0, 0, 640, 480, this);
      g2d.finalize();
      g2d.dispose();
  
      LuminanceSource source = new BufferedImageLuminanceSource(myImage,0,0,640,480);
      BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
      try{
        
        Result result = reader.decode(bitmap, hints);

        String text = result.getText();
        byte[] rawBytes = result.getRawBytes();
        BarcodeFormat format = result.getBarcodeFormat();
        ResultPoint[] points = result.getResultPoints();
        
        long ean = Long.parseLong(text);
        println("ean is "+ ean);
        if(!gardenContains(monsterList, ean)) {  
          println("You found a new monster!");
          AbstractMonster m = createMonster(ean, null);
          monsterList.add(m);
          updateGarden();
          saveGarden(monsterList);
          showNewestMonsterInGarden();
        }else{
          println("This monster is already in your garden.");
        }
      }catch(NotFoundException ex) {
        print(".");
      }catch(ChecksumException ex) {
        println(ex.toString());
      }catch(FormatException ex) {
        println(ex.toString());
      }
      reader.reset();

  }else if(theEvent.controller().name().equals("garden"))
  {
    previous.show();
    next.show();
    free.show();
    knob.show();
    mode = GARDEN;

     
        
     gardenIterator = (gardenIterator + 1) % monsterList.size();
     updateGarden();
    
  }else if(theEvent.controller().name().equals("previous")){
    gardenIterator = (gardenIterator -1 + monsterList.size()) % monsterList.size();
    updateGarden();
  }else if(theEvent.controller().name().equals("next")){
    gardenIterator = (gardenIterator + 1) % monsterList.size();
    updateGarden();
  }else if(theEvent.controller().name().equals("free")){
    monsterList.remove(gardenIterator);
    updateGarden();
    saveGarden(monsterList);
  }else if(theEvent.controller().name().equals("knob")){
    
  }else{
    mode = NOTHING;
  }
  
  if(mode != GARDEN){
    next.hide();
    previous.hide();
    free.hide();
    knob.hide();
  }
  
}

void keyPressed() {
  
}

void showNewestMonsterInGarden() {
  gardenIterator = monsterList.size()-1;
  knob.setValue(gardenIterator);
  mode = GARDEN;
}

void updateGarden() {
  gardenIterator = gardenIterator % monsterList.size();
  gardenExemplum = (AbstractMonster)monsterList.get(gardenIterator);
  if(knob != null) {
    knob.setMax(monsterList.size());
    knob.setValue(gardenIterator);
  }
}

void draw() {
  background(255);
  if(mode == CATCH)
  {
    set(0,0,cam);
    filter(GRAY);
  }else if(mode == GARDEN)
  {
    gardenExemplum.display();
    gardenExemplum.displayData();
  }
  
}

void saveGarden(ArrayList list) {
  PrintWriter output = createWriter(saveFile);
  Iterator it = list.iterator();
  AbstractMonster m;
  while(it.hasNext()){
    m = (AbstractMonster)it.next();
    output.println(m.ean + ";" + m.id);
  }
  output.flush(); // Write the remaining data
  output.close(); // Finish the file
}

void loadGarden(ArrayList list) {
  
  try{
  String[] lines = loadStrings(saveFile);
  String[] pieces;
  for(int i = 0; i < lines.length; i++) {
    pieces = splitTokens(lines[i], "\t;");
    if(pieces.length == 2)
      list.add(createMonster(Long.parseLong(pieces[0]), pieces[1]));
    else
      list.add(createMonster(Long.parseLong(pieces[0]), null));
  }
  }catch(Exception ex){
    println("Could not read " + saveFile +", "+ex.toString());
  }
}

boolean gardenContains(ArrayList l, long ean) {
 Iterator it = l.iterator();
 boolean ret = false;
 while(it.hasNext()) {
   ret = ret || ((AbstractMonster)it.next()).ean == ean;
 }
 return ret;
  
}

AbstractMonster createMonster(long ean, String id) {
  randomSeed((int)ean);
//  println("create Monster");
//  println(ean);
  AbstractMonster m;
  switch((int)random(100)) {
    case 0:
    default:
      m = new MoMoMonster(ean, id);
      break;
  }
    
  return m;
}



void stop() {
  cam = null;
  video = null; 
}

void dispose() {
  cam = null;
  video = null;   
}

