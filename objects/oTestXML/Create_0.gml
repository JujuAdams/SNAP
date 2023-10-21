var _string = @'
<?xml version="1.0" encoding="utf-8"?>
<bookstore>  
  <book category="COOKING">  
    <title lang="en">Everyday Italian</title>  
    <author>Giada De Laurentiis</author>  
    <year>2005</year>  
    <price>30.00</price>  
  </book>  
  <book category="TOILET PAPER">  
    <title lang="en">Harry Potter</title>  
    <author>J K. Rowling</author>  
    <year>2005</year>  
    <price>0.49</price>  
  </book>  
  <book category="WEB">  
    <author>Erik T. Ray</author>  
    <title lang="en">Learning XML</title>  
    <year>2003</year>  
    <price>39.95</price>  
  </book>  
</bookstore>';

var _struct = SnapFromXML(_string);
show_debug_message(SnapVisualize(_struct));
show_debug_message(SnapToXML(_struct, false));
show_debug_message(SnapToXML(_struct, true ));