 /*
 * Copyright (c) 2008 John McMullen (http://www.smple.com)
 * This is licensed under GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
*/ 
 
 (function($){
	$.fn.pagePeel = function(options){
	
		var defaults = {
			
			// SET WIDTH / HEIGHT OF CORNER AD (SAME AS .SWF)
			smallWidth: 100,
			smallHeight: 100,
			smallBG: 'http://www.yourdomain.com/pagePeel/pp-src/smallBG.png',
			smallAd: 'http://www.yourdomain.com/pagePeel/pp-src/testAdSmall.png',
			smallSWF:'http://www.yourdomain.com/pagePeel/pp-src/page-peel-small.swf',
			
			// SET WIDTH / HEIGHT OF INTRO AD (SAME AS .SWF)
			introWidth: 300,
			introHeight:300,
			introAd: 'http://www.yourdomain.com/pagePeel/pp-src/testIntroAd.png',
			introSWF:'http://www.yourdomain.com/pagePeel/pp-src/page-peel-intro.swf',
			
			// SET WIDTH / HEIGHT OF BIG AD (SAME AS .SWF)
			bigWidth: 500,
			bigHeight: 500,
			bigBG: 'http://www.yourdomain.com/pagePeel/pp-src/bigBG.png',
			bigAd: 'http://www.yourdomain.com/pagePeel/pp-src/testAdBig.png',
			bigSWF:'http://www.yourdomain.com/pagePeel/pp-src/page-peel-big.swf',
			
			// POSITION WILL REMAIN THE SAME FOR BOTH
			hPosition: 'right', // can use 'left' or 'right'
			vPosition: 'top', // can use 'top' or 'bottom'
			
			// CHOOSE WHETHER TO USE FLASH OR NOT
			flash: true,
			
			// WHETHER TO USE INTRO ANIMATION OR NOT
			introAnim: false,
			
			// ADD LINK IF LEFT 'BLANK', NO ADD LINK WILL BE APPLIED
			adLink: 'http://www.yourdomain.com'
		};
		
		var options = $.extend(defaults, options);
		
		var element = this;
		
	return this.each(function(){
		
		if (options.flash === true){
			if (options.introAnim === true){
				$(element).before("<div id='page-peel-intro' style='width:" + options.introWidth + "px; height: " + options.introHeight + "px; display:block; position:absolute; " + options.vPosition + ":0px; " + options.hPosition + ":0px; z-index:9980;'><embed style='display: block;' src='" + options.introSWF + " 'flashvars='introURL=" + options.introAd + "' type='application/x-shockwave-flash' pluginspage='http://www.adobe.com/go/getflashplayer' wmode='transparent' autoplay='false' width='" + options.introWidth + "' height='" + options.introHeight + "'></div> <div id='page-peel-big' style='width:" + options.bigWidth + "px; height: " + options.bigHeight + "px; display:none; position:absolute; " + options.vPosition + ":0px; " + options.hPosition + ":0px; z-index:9999;'><embed style='display: block;' src='" + options.bigSWF + "' flashvars='bigURL=" + options.bigAd + "&amp;linkURL=" + options.adLink + "' type='application/x-shockwave-flash' pluginspage='http://www.adobe.com/go/getflashplayer' wmode='transparent' autoplay='false' width='" + options.bigWidth + "' height='" + options.bigHeight + "'></div><div id='page-peel-small' style='width:" + options.smallWidth + "px; height: " + options.smallHeight + "px; display:block; position:absolute; " + options.vPosition + ":0px; " + options.hPosition + ":0px; z-index:9990;'><embed style='display: block;' src='" + options.smallSWF + " 'flashvars='smallURL=" + options.smallAd + "' type='application/x-shockwave-flash' pluginspage='http://www.adobe.com/go/getflashplayer' wmode='transparent' autoplay='false' width='" + options.smallWidth + "' height='" + options.smallHeight + "'></div>");
			} else {
				$(element).before("<div id='page-peel-small' style='width:" + options.smallWidth + "px; height: " + options.smallHeight + "px; display:block; position:absolute; " + options.vPosition + ":0px; " + options.hPosition + ":0px; z-index:9990;'><embed style='display: block;' src='" + options.smallSWF + " 'flashvars='smallURL=" + options.smallAd + "' type='application/x-shockwave-flash' pluginspage='http://www.adobe.com/go/getflashplayer' wmode='transparent' autoplay='false' width='" + options.smallWidth + "' height='" + options.smallHeight + "'></div> <div id='page-peel-big' style='width:" + options.bigWidth + "px; height: " + options.bigHeight + "px; display:none; position:absolute; " + options.vPosition + ":0px; " + options.hPosition + ":0px; z-index:9999;'><embed style='display: block;' src='" + options.bigSWF + " 'flashvars='bigURL=" + options.bigAd + "' type='application/x-shockwave-flash' pluginspage='http://www.adobe.com/go/getflashplayer' wmode='transparent' autoplay='false' width='" + options.bigWidth + "' height='" + options.bigHeight + "'></div>");
			}
		}
		
		if (options.flash === false){
			$(element).before("<div id='page-peel-small' style='width:" + options.smallWidth + "px; height: " + options.smallHeight + "px; display:block; position:absolute; " + options.vPosition + ":0px; " + options.hPosition + ":0px; background:url(" + options.smallBG + ") top left no-repeat; z-index:9999;'></div> <div id='page-peel-big' style='width:" + options.bigWidth + "px; height: " + options.bigHeight + "px; display:none; position:absolute; " + options.vPosition + ":0px; " + options.hPosition + ":0px; background:url(" + options.bigBG + ") top left no-repeat; z-index:9999;'></div>");
		}
		
		//$('#page-peel-small').css({border: "red 1px solid"});
		//$('#page-peel-big').css({border: "red 1px solid"});
		
		if (options.introAnim === true){
		
			$('#page-peel-small').hide();
			  
			$('#page-peel-intro').mouseover(
				function(){
					$(this).hide();
					$('#page-peel-small').show();
				}
			);
		}
		
		$('#page-peel-small').mouseover(
			function(){
				// $(this).hide();
				$('#page-peel-big').stop().show();			
			}
		);
		
		$('#page-peel-big').mouseout(
			function(){
				$(this).animate({right:'0px'},600).fadeOut('fast', function() {$(this).hide();});
				// $('#page-peel-small').show();
			}
		);
	});
		// alert ('page peel');
		
	};
})(jQuery);