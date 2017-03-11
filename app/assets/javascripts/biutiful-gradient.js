(function( $ ) {
 
    $.fn.biutifulGradient = function(options) {

    	var settings = $.extend({
    		color1: '#cc208e',
    		color2: '#6713d2',
    		angleDeg: '180'
    	}, options)

    	var bg = "linear-gradient(" + settings.angleDeg + "deg, " + settings.color1 + " 0" + "%, " + settings.color2 + " 100%)",
    		bgO =  "-o-linear-gradient(" + settings.angleDeg + "deg, " + settings.color1 + " 0" + "%, " + settings.color2 + " 100%)",
        bgWebkit =  "-webkit-linear-gradient(" + settings.angleDeg + "deg, " + settings.color1 + " 0" + "%, " + settings.color2 + " 100%)",
    		bgMoz =  "linear-gradient(" + settings.angleDeg + "deg, " + settings.color1 + " 0" + "%, " + settings.color2 + " 100%)"

   		this.css("background-image", bg)
      this.css("background-image", bgO)
   		this.css("background", bgMoz)
   		this.css("background-image", bgWebkit)

   		this.on('mousemove', function () { // Set background on move
   			var width = $(this).width(),
		        height = $(this).height(),
		        maxDistance = Math.sqrt(width*width + height*height)
		    var x = event.pageX - width/2,
		        y = event.pageY - height/2
		    var polarCoord = cart2Polar(x, y)
		    var percent = Math.round(polarCoord.d*200/maxDistance)*0.4
		    var bg = "linear-gradient(" + (polarCoord.deg - 90) + "deg," + settings.color1 + " " + (percent) +"%, " + settings.color2 + " " + (100-percent)+ "%)"
        var bgO = "-o-linear-gradient(" + (polarCoord.deg - 90) + "deg," + settings.color1 + " " + (percent) +"%, " + settings.color2 + " " + (100-percent)+ "%)"
		    var bgMoz = "linear-gradient(" + (polarCoord.deg - 90) + "deg," + settings.color1 + " " + (percent) +"%, " + settings.color2 + " " + (100-percent)+ "%)"
		    var bgWebkit = "-webkit-linear-gradient(" + (polarCoord.deg - 90) + "deg," + settings.color1 + " " + (percent) +"%, " + settings.color2 + " " + (100-percent)+ "%)"
        $(this).css("background-image", bg);
        $(this).css("background-image", bgO);
        $(this).css("background-image", bgWebkit);
		    $(this).css("background", bgMoz);
   		})
        return this;
 
    };
 
}( jQuery ));

function cart2Polar(x, y){
    distance = Math.sqrt(x*x + y*y)
    radians = Math.atan2(y,x) //This takes y first
    degrees = radians * 360 / (2*Math.PI)
    polarCoord = { d:distance, rad:radians, deg: degrees }
    return polarCoord
}