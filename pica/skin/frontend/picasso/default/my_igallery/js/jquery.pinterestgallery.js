/* 
	Author: http://codecanyon.net/user/sike
*/      
;(function($){      
	
	var _currentLargeNum;
	function clickCard(event){
		var _item = $(event.data.target);
		var _this = event.data.root;
		var settings = _this.data('settings');
		var _url = _item.data('large');
		var _container = $('div#' + settings.largeContainerID);
		var _assetCon = _container.find('div.assetContainer');	
		var _closeButton = _assetCon.find('div.closeButton');	
		var _arrowButton = _container.find('div.arrowButton');
		_currentLargeNum = $.inArray(_url, _this.data('largeArr'));
		if(_assetCon[0]==null||_assetCon[0]==undefined){
			_assetCon = $('<div class="assetContainer"></div>').css('position', 'relative');			
			_container.append(_assetCon);					
			_closeButton = $('<div class="closeButton"></div>');								
			_assetCon.append(_closeButton);
			_closeButton.css('cursor', 'pointer').on('click', function(event) {
				_container.animate({opacity: 0}, 300, function(){
					$(this).hide();
					_container.find('img').remove();
					_container.find('span').remove();
					_container.find('iframe').remove();					
				});
			});

			_container.on('click', function(event) {
				if($(event.target).is('div#' + settings.largeContainerID)||$(event.target).is(_assetCon)){
					_container.animate({opacity: 0}, 300, function(){
						$(this).hide();
						_container.find('img').remove();
						_container.find('span').remove();
						_container.find('iframe').remove();					
					});
					
				}

			});
			
			
			_arrowButton = $('<div id="arrowButton"><div class="prevArrow"></div><div class="nextArrow"></div></div>');	   		 			
			_container.append(_arrowButton);
			var _nextBtn, _prevBtn, arrowHeight;
            _nextBtn = $('.nextArrow', _arrowButton).on('click', function(event) {
				var _n = _currentLargeNum;
				_n++;
				if(_n>_this.data('largeArr').length-1) _n = 0;	    
				openAsset(_this.data('itemArr')[_n], _this);
            });;
            _prevBtn = $('.prevArrow', _arrowButton).on('click', function(event) {
				var _n = _currentLargeNum;
				_n--;
				if(_n<0) _n = _this.data('largeArr').length-1;	    
				openAsset(_this.data('itemArr')[_n], _this);	
            });
			arrowHeight = _nextBtn.height();
			var mh = Math.ceil(($(window).height()-arrowHeight)*.5);
			_arrowButton.css('top', mh);	                               
			$(window).resize(function(event){
				var mh = Math.ceil(($(window).height()-arrowHeight)*.5);
				_arrowButton.css('top', mh);	 					
				var _aw = _assetCon.find('img').outerWidth() || _assetCon.find('iframe').outerWidth();
				var _ah = _assetCon.find('img').outerHeight() || _assetCon.find('iframe').outerHeight();
				_assetCon.css({
					'marginTop': ($(window).height() - _ah)*.5 + 'px',
					'marginLeft': ($(window).width() - _aw)*.5 + 'px'										
				});					
								
			});
			
		}
		
		openAsset(_item, _this);
		event.stopImmediatePropagation();
	}
	
	function openAsset(_item, _this){
		var settings = _this.data('settings');
		var _type = _item.data('type');
		var _url = _item.data('large');
		var _container = $('div#' + settings.largeContainerID);
		var _assetCon = _container.find('div.assetContainer');	
		var _closeButton = _assetCon.find('div.closeButton').css('opacity', 0);	
		var _arrowButton = _container.find('div.arrowButton');
		_currentLargeNum = $.inArray(_url, _this.data('largeArr'));
		
		
		_assetCon.css('opacity', 0);		
		_container.find('img').remove();
		_container.find('span').remove();
		_container.find('iframe').remove();							
		
		if(_url!=""&&_url!=undefined){
			_container.show().stop(true, true).animate({opacity: 1}, 300, function(){
				if(_type!='video'){
					$('<img/>').load( function() {	
						 _assetCon.append('<img src="' + _url + '"/>');
						 var _img = _container.find('img');
						_assetCon.css({
							'marginTop': ($(window).height() - this.height)*.5 + 'px',
							'marginLeft': ($(window).width() - this.width)*.5 + 'px'										
						});			
						 //_assetCon.removeClass('backSide').addClass('normal');						
						_assetCon.stop(true, true).animate({opacity: 1}, 300);
						_closeButton.css({
						  left: this.width - 13 + 'px'
						}).delay(400).animate({opacity: 1}, 300);
					}).attr( 'src', _url);
		
				}else{
					var _width = _item.data('width');
					var _height = _item.data('height');
		 			_assetCon.stop(true, true).animate({opacity: 1}, 300).append('<iframe src="' + _url + ' + "width="'+_width+'"height="'+_height+'"frameborder="0" webkitAllowFullScreen allowFullScreen />');				
					_closeButton.css('left', _width - 13 + 'px').delay(400).animate({opacity: 1}, 300);

					_assetCon.css({
						'marginLeft': ($(window).width() - _width)*.5 + 'px',						
						'marginTop': ($(window).height() - _height)*.5 + 'px'
					});			
				
				
				
				}				
			
			});			
		}	
		
	}
		
	function overCard(event){
		var _item = $(event.data.target);
		var settings = event.data.root.data('settings');
		var _frontContainer = _item.find('.'+settings.frontContainer);
		var _backContainer = _item.find('.'+settings.backContainer);
		
		_item.stop(true, true).animate({opacity: 1}, 100);	
		if(!Modernizr.csstransitions){
			_frontContainer.css('z-index', 800).animate({opacity:0}, 300);
			_backContainer.css('z-index', 900).animate({opacity:1}, 300);
		}else{
			_frontContainer.css('z-index', 800).removeClass('normal').addClass(settings.animateStyle + ' frontSide');
			_backContainer.css('z-index', 900).removeClass('backSide').addClass(settings.animateStyle + ' normal');	
		}
		event.stopImmediatePropagation();
	}
			
	function outCard(event){
		var _item = $(event.data.target);
		var settings = event.data.root.data('settings');			
		var _frontContainer, _backContainer;
		_item.stop(true, true).animate({opacity: 1}, settings.animateDelay, function() {
			_frontContainer = _item.find('.'+settings.frontContainer);
			_backContainer = _item.find('.'+settings.backContainer);
			if(!Modernizr.csstransitions){
	 			_frontContainer.css('z-index', 900).animate({opacity:1}, 300);
				_backContainer.css('z-index', 800).animate({opacity:0}, 300);
				
			}else{
	 			_frontContainer.css('z-index', 900).removeClass('frontSide').addClass('normal');
				_backContainer.css('z-index', 800).removeClass('normal').addClass('backSide');
				
			}
			
		})
		event.stopImmediatePropagation();
	}
				
	$.fn.extend({
		pinterestGallery: function(options) {
	      	// plugin default options, it's extendable
			var settings = { 
				largeContainerID:'theLarge',
				gridOptions: {
			        autoResize: true, // This will auto-update the layout when the browser window is resized.
			        container: $('#main'), // Optional, used for some extra CSS styling
			        offset: 2, // Optional, the distance between grid items
			        itemWidth: 210 // Optional, the width of a grid item					
				},		
				frontContainer: 'front', 
				backContainer: 'back',
				animateStyle: 'twirl',
				animateDelay: '400'				
			}; 
			
  			// extends settings with options provided
	        if (options) {
				$.extend(settings, options);
			} 

			var _this = this; 			
			_this.data('settings', settings);
			
			
		    // Get a reference to your grid items.
	    	var handler = _this.find('li');
			handler.wookmark(settings.gridOptions);     			
			var _container = $('div#' + settings.largeContainerID);					
			_container.css('opacity', 0).hide();
			
			var _frontContainer, _backContainer;
			var _largeArr = [], _itemArr = [];
			var _largeIndex = 0;
			_this.find('li').each(function(index) {
				_frontContainer = $(this).find('.'+settings.frontContainer);
				_backContainer = $(this).find('.'+settings.backContainer);
				if($(this).data('large')!=undefined){
					$(this).css('cursor', 'pointer');
					_itemArr[_largeIndex] = $(this);
					_largeArr[_largeIndex] = $(this).data('large');
					_largeIndex++;
				}
				if(!Modernizr.csstransitions){
					_backContainer.css({
						'z-index': 800,
						'opacity': 0
					});
					_frontContainer.css('z-index', 900);
					
				}else{
					_backContainer.css('z-index', 800).addClass(settings.animateStyle + ' backSide');
					_frontContainer.css('z-index', 900);					
				}
								
			  	$(this).on('mouseover', {target:$(this), root:_this}, overCard);
				$(this).on('mouseleave', {target:$(this), root:_this}, outCard);				
				$(this).on('click', {target:$(this), root:_this}, clickCard);								
				$(this).find('.back').css('height', $(this).find('.front').outerHeight())				
			});
			_this.data('itemArr', _itemArr);			
			_this.data('largeArr', _largeArr);
								
			return this;
		}

	});
		
})(jQuery);