//struct = {
//    a : true,
//    b : false,
//    c : undefined,
//    d : 1/9,
//    e : 15/100,
//    array : [
//        5,
//        6,
//        7,
//        {
//            struct : "struct!",
//            nested : {
//                nested : "nested!",
//                array : [
//                    "more",
//                    "MORE",
//                    "M O R E"
//                ]
//            }
//        }
//    ],
//    test : "text!",
//    test2 : "\"Hello world!\"",
//    url : "https://www.jujuadams.com/"
//};

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




snap = snap_from_xml_string(_string);
show_debug_message(snap_to_json_string(snap, true, true));
show_debug_message(snap_to_xml_string(snap));