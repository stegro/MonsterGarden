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
int HUNT = 1;
int NOTHING = 0;
int GARDEN = 2;

//operating system
String os;

//GSVideo
GSCapture cam;

//ControlP5
ControlP5 controlP5;
MultiList l;

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
//    numPixels = video.width * video.height;
//    gridSizeX = video.width / numGridX;
//    gridSizeY = video.height / numGridY;
  }
 
 
  
  controlP5 = new ControlP5(this);
  
  // add a multiList to controlP5.
  // elements of the list have default dimensions
  // here, a width of 100 and a height of 12
  l = controlP5.addMultiList("myList",0,10,100,12);
  
  // create a multiListButton which we will use to
  // add new buttons to the multilist
  MultiListButton menu, item;
  menu = l.add("Menu",1);
  menu.setColorBackground(color(0,0,0));  
  menu.setColorForeground(color(HOVER_GRAY,HOVER_GRAY,HOVER_GRAY));
  menu.setColorActive(color(255,255,255));
  
  // add items to a sublist of button "level1"
  item = menu.add("hunt",11);
  item.setLabel("hunt a monster");
  item.setColorBackground(color(0,0,0));
  item.setColorForeground(color(HOVER_GRAY,HOVER_GRAY,HOVER_GRAY));
  item.setColorActive(color(255,255,255));
  
  item = menu.add("garden",12);
  item.setLabel("garden");
  item.setColorBackground(color(0,0,0));
  item.setColorForeground(color(HOVER_GRAY,HOVER_GRAY,HOVER_GRAY));
  item.setColorActive(color(255,255,255));
  
/*  MultiListButton cc = (MultiListButton)controlP5.controller("menu");
  cc.setHeight(40);
  */
}





void controlEvent(ControlEvent theEvent) 
{
  //println(theEvent.controller().name()+" = "+theEvent.value());  

  if(!theEvent.controller().name().equals("hunt")){
    if(os.equals("linux"))
      cam.pause();
    else
      video.stop();
  }
  if(theEvent.controller().name().equals("hunt"))
  {
    mode = HUNT;
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
  
        println("Content is: '" + text+"'");
        
        long ean = Long.parseLong(text);
        println("ean is "+ ean);
        if(!gardenContains(monsterList, ean)) {  
          println("You found a new monster!");
          AbstractMonster m = createMonster(ean);
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
     mode = GARDEN;
        
     gardenIterator = (gardenIterator + 1) % monsterList.size();
     updateGarden();
    
  }else{
    mode = NOTHING;
  }
  
}

void showNewestMonsterInGarden() {
  gardenIterator = monsterList.size()-1;
  mode = GARDEN;
}

void updateGarden() {
  gardenIterator = gardenIterator % monsterList.size();
  gardenExemplum = (AbstractMonster)monsterList.get(gardenIterator);
}

void draw() {
  background(255);
  if(mode == HUNT)
  {
    set(0,0,cam);
    filter(GRAY);
    filter(POSTERIZE,200);
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
    output.println(m.ean);
  }
  output.flush(); // Write the remaining data
  output.close(); // Finish the file
}

void loadGarden(ArrayList list) {
  
  try{
  String[] lines = loadStrings(saveFile);
  String[] pieces;
  for(int i = 0; i < lines.length; i++) {
    pieces = splitTokens(lines[i], "\t");
    list.add(createMonster(Long.parseLong(pieces[0])));
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

AbstractMonster createMonster(long ean) {
  randomSeed((int)ean);
  println("create Monster");
  println(ean);
  AbstractMonster m;
  switch((int)random(100)) {
    case 0:
    default:
      m = new MoMoMonster(ean);
      break;
  }
    
  return m;
}
