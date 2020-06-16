var _string = @'
<?xml version="1.0" encoding="utf-8"?>
<bookstore>  
  <book category="COOKING">  
    <title lang="en">Everyday Italian</title>  
    <author>Giada De Laurentiis</author>  
    <year>2005</year>  
    <price>30.00</price>  
  </book>  
  <book category="CHILDREN">  
    <title lang="en">Harry Potter</title>  
    <author>J K. Rowling</author>  
    <year>2005</year>  
    <price>29.99</price>  
  </book>  
  <book category="WEB">  
    <title lang="en">Learning XML</title>  
    <author>Erik T. Ray</author>  
    <year>2003</year>  
    <price>39.95</price>  
  </book>  
</bookstore>';

var _struct = snap_from_xml(_string);
show_debug_message(snap_to_json(_struct, true, true));
show_debug_message(snap_to_xml(_struct, false));
show_debug_message(snap_to_xml(_struct, true ));