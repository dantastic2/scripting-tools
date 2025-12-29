//<script type="text/javascript" src="news.js"></script> 

	function unescapeHTML(escapedHTML) {
	  return escapedHTML.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&');
	}
	
	function ROTn(text, map) {
	  // Generic ROT-n algorithm for keycodes in MAP.
	  var R = new String()
	  var i, j, c, len = map.length
	  for(i = 0; i < text.length; i++) {
		c = text.charAt(i)
		j = map.indexOf(c)
		if (j >= 0) {
		  c = map.charAt((j + len / 2) % len)
		}
		R = R + c
	  }
	  return R;
	}
	
	function ROT47(text) {
	  // Hides all ASCII-characters from 33 ("!") to 126 ("~").  Hence can be used
	  // to obfuscate virtually any text, including URLs and emails.
	  var R = new String()
	  R = ROTn(text,
	  "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
	  return R;
	}
	const paragraphs = document.getElementsByClassName("subscriber-only encrypted-content");
	for(var i = 0, length = paragraphs.length; i < length; i++) {
          paragraphs[i].innerHTML = ROT47(unescapeHTML(paragraphs[i].innerHTML));
       }
