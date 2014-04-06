// Local namespace
(function($) {
    // Namespace constants
    var PAGE_TITLE_PREF = 'JS Application Design : ';
    // Application namespace
    var App = function() {
        // Application event handlers
        var _handler = {
            introOnChange : function(e, node) {
                document.title = PAGE_TITLE_PREF + $(node).attr('title');
            }
        };
        return {
            init : function(settings) {
                //App.syncUI();
                // Invoke the first instance of Intro
                settings['uploaderSelector'] = 'file-uploader-demo1';
                settings['boundingBox'] = $('#file-uploader-demo1');
                App.ImageEditor(settings).getInstance();
            },
            syncUI : function() {

            }
        }
    }();
    //  Module
    App.ImageEditor = function(settings) {
        // Module constants
        var UPLOAD_ACTION = settings.siteUrl + 'picasso/upload';
        var GET_IMAGE_URL = settings.siteUrl + 'picasso/image';
        var CONVERT_IMAGE_URL = settings.siteUrl + 'picasso/image/convert';
        var PROCESS_IMAGE_URL = settings.siteUrl + 'picasso/upload/processThumbImage';
        var PROCESS_MAIN_IMAGE_URL = settings.siteUrl + 'picasso/upload/processMainImage';
        var DOWNLOAD_IMAGE_URL = settings.siteUrl + 'picasso/upload/download';
        var IMAGE_SIZE_LIMIT = settings.imageSizeAllow;
        var IMAGE_EXT_ALLOW = settings.imageExtAllow;
        var TIME_RELOAD_IMAGE = null;
        // Private properties
        var _imageZoom = null;
        var _currentImagePath = null;
        var _selectedImagePath = null;
        var _imageCrop = null;
        var _uploadList = {};
        var _selectedUpload = null;

        // event handlers
        var _handler = {
            onUploaderComplete : function(e, id, fileName, responseJson, selected) {
                for (var k in _uploadList) {
                    _uploadList[k]['selected'] = false;
                }

                $('#qq-upload-item-id' + id).prepend('<span class="qq-image-upload-thumb"><img style="width:50px;height:50px" src="' + responseJson.imageUrl + '"/></span>').data('arguments', [id, fileName, responseJson, false]).click(function() {

                    var args = $(this).data('arguments');
                    $('.qq-upload-success').removeClass('active');
                    $(this).addClass('active');

                    _handler.updateEditor.apply(this, args);
                    var effectSelected = $(this).attr('effect_selected');
                    $('#' + effectSelected).click();
                    for (var k in _uploadList) {
                        _uploadList[k]['selected'] = false;
                    }
                    _uploadList[id]['selected'] = true;
                    _selectedUpload = _uploadList[id];
                    $('#upload_list').val($.toJSON(_uploadList));
                }).append('<span style="line-height:40px;color:red" id="qq-upload-remove-item-id' + id + '">X</span>');

                if ( typeof (selected) == 'boolean') {
                    if (selected) {
                        _uploadList[id] = {
                            'filename' : fileName,
                            'responseJson' : responseJson,
                            'selected' : true
                        };
                        _handler.updateEditor(id, fileName, responseJson, false);
                        $('#qq-upload-item-id' + id).click();

                        _imageZoom.iviewer('loadImage', _uploadList[id].currentImageUrl);
                        $('a.share-link-button').each(function() {
                            var linkTemplate = $(this).attr('link_template');
                            var link = linkTemplate.replace('{ADDRESS}', encodeURIComponent(_uploadList[id].currentImageUrl)).replace('{BLOGURL}', encodeURIComponent(window.location.href)).replace('{IMAGE}', encodeURIComponent(_uploadList[id].currentImageUrl));
                            $(this).attr('href', link);
                        });
                    } else {
                        _uploadList[id] = {
                            'filename' : fileName,
                            'responseJson' : responseJson,
                            'selected' : false
                        };
                    }
                } else {
                    _uploadList[id] = {
                        'filename' : fileName,
                        'responseJson' : responseJson,
                        'selected' : true
                    };
                    _handler.updateEditor(id, fileName, responseJson, true);
                }

                $("#qq-upload-remove-item-id" + id).live('click', function() {
                    $(this).parent().remove();
                });

                if ( typeof (_uploadList[id].effectSelected) != 'undefined') {
                    $('#qq-upload-item-id' + id).attr('effect_selected', responseJson.effectSelected);
                }
                $('#upload_list').val($.toJSON(_uploadList));
            },

            updateEditor : function(id, fileName, responseJson, isProcessThumb) {
                $(".selectable").children("li").each(function() {
                    $(this).data('imgLoad', '');
                });
                $('#upload-image').hide();
                //Johnny
                //Show loading image
                $('#image-editor-main-image').css('background-image', 'url(../skin/frontend/picasso/default/sm/images/loading10.gif)');

                _imageZoom.iviewer('loadImage', responseJson.imageUrl);
                _selectedImagePath = responseJson.imagePath;
                $('#file-path-image-selected').val(_selectedImagePath);

                $('#org-image-upload-container').html('<img style="width:100%;display:none" src="' + responseJson.imageUrl + '" id="org-image-upload"/>')
                $('#org-image-upload-clone').attr('src', responseJson.imageUrl);
                $('#org-image-src').val(responseJson.imageUrl);

                $('#effect-selected').val(settings.defaultEffect);
                $('#file-image-selected').val(responseJson.imageUrl);

                $('#org-image-upload').show().attr('src', responseJson.imageUrl);
                $('a.share-link-button').each(function() {
                    var linkTemplate = $(this).attr('link_template');
                    var link = linkTemplate.replace('{ADDRESS}', encodeURIComponent(responseJson.imageUrl)).replace('{BLOGURL}', encodeURIComponent(window.location.href)).replace('{IMAGE}', encodeURIComponent(responseJson.imageUrl));
                    $(this).attr('href', link);
                });
                var images = responseJson.images;
                _currentImagePath = responseJson.imagePath;

                for (i in images) {
                    var image = images[i];
                    var srcImg = image.image_output;

                    $('#image-effect-' + image.effect).attr('image_url', srcImg);
                    $('#image-effect-' + image.effect).children('div.effect-thumb').html('<img onload="imageThumbLoaded(this)" onerror="reloadImage(this,\'' + srcImg + '\')"  src="' + srcImg + '"/>');
                }
                if (isProcessThumb) {
                    $.ajax({
                        url : PROCESS_IMAGE_URL,
                        type : 'POST',
                        data : responseJson,
                        dataType : 'json',
                        async : true,
                        success : function(data) {
                            var images = data.images;
                            var imagesJson = $.toJSON(images);
                            $('#image-effects').val(imagesJson);
                            $('#org-image-path').val(data.imagePath);
                        }
                    });
                } else {
                    var images = responseJson.images;
                    var imagesJson = $.toJSON(images);
                    $('#image-effects').val(imagesJson);
                    $('#org-image-path').val(responseJson.imagePath);
                }
            },

            reloadEffect : function() {
                var effect = $('#effect-selected').val();
                var crop = {};
                var brightnessContrast = {};
                if (effect != '' && _currentImagePath != '') {
                    if ( typeof (_imageCrop) != 'undefined' && _imageCrop != null && typeof (_imageCrop.tellSelect()) != 'undefined') {

                        var cropArea = _imageCrop.tellSelect();

                        var imageViewerW = $('#org-image-upload-clone').width();
                        var imageViewerH = $('#org-image-upload-clone').height();
                        var imageCropW = $('#org-image-upload').width();
                        var imageCropH = $('#org-image-upload').height();

                        var dW = parseFloat(imageCropW) / parseFloat(imageViewerW);
                        var dH = parseFloat(imageCropH) / parseFloat(imageViewerH);

                        crop['x'] = parseInt(parseFloat(cropArea.x) / dW);
                        crop['y'] = parseInt(parseFloat(cropArea.y) / dH);
                        crop['w'] = parseInt(parseFloat(cropArea.w) / dW);
                        crop['h'] = parseInt(parseFloat(cropArea.h) / dH);

                        var cropSelect = [cropArea.x, cropArea.y, cropArea.x2, cropArea.y2];

                        $('#crop-select').val(cropSelect.join(','));
                    }

                    brightnessContrast = {
                        'brightness' : $('#brightness-control').slider("value"),
                        'contrast' : $('#contrast-control').slider("value")
                    };

                    $.ajax({
                        url : PROCESS_MAIN_IMAGE_URL,
                        type : 'POST',
                        data : {
                            'image_path' : _currentImagePath,
                            'effect_id' : effect,
                            'crop' : crop,
                            'brightness_contrast' : brightnessContrast
                        },
                        dataType : 'json',
                        async : true,
                        success : function(data) {
                            _imageZoom.iviewer('loadImage', data.src);
                            if (_selectedUpload) {
                                _selectedUpload['currentImageUrl'] = data.src;
                            }
                            $('a.share-link-button').each(function() {
                                var linkTemplate = $(this).attr('link_template');
                                var link = linkTemplate.replace('{ADDRESS}', encodeURIComponent(data.src)).replace('{BLOGURL}', encodeURIComponent(window.location.href)).replace('{IMAGE}', encodeURIComponent(data.src));
                                $(this).attr('href', link);
                            });

                            $('#file-image-selected').val(data.src);
                            $('#effect-selected').val(effect);
                            _selectedImagePath = data.path;
                            $('#file-path-image-selected').val(_selectedImagePath);
                        }
                    });
                }
            }
        };

        return $.jsa.extend({
            name : 'Intro',
            HTML_PARSER : {
                toolbar : '#image-editor-toolbar',
                imageList : '#image-editor-image-list',
                effectList : '#image-editor-effect-list'
            },
            init : function() {

            },
            renderUI : function() {
                var uploader = new qq.FileUploader({
                    element : document.getElementById('file-uploader-demo1'),
                    action : UPLOAD_ACTION,
                    allowedExtensions : IMAGE_EXT_ALLOW,
                    sizeLimit : IMAGE_SIZE_LIMIT,
                    onComplete : function(id, fileName, responseJSON) {
                        $(document).trigger('uploader-oncomplete', [id, fileName, responseJSON]);

                    }
                });

                _imageZoom = $("#image-editor-main-image").iviewer({
                    onStartLoad : function(e, src) {
                        $('#image-editor-main-image').children('img').hide();
                    },
                    onFinishLoad : function(e, src) {
                        $('#image-editor-main-image').children('img').show();
                    }
                });

                // edit image

                if (( typeof settings.currentImageEdit) != 'undefined') {
                    for (var j in settings.currentImageEdit.uploadList) {
                        var uploadItem = settings.currentImageEdit.uploadList[j];
                        var index = j + 100;
                        _uploadList[index] = uploadItem;
                        var selectedEffect = '';
                        if ( typeof (uploadItem.selectedEffect) != "undefined") {
                            selectedEffect = uploadItem.selectedEffect;
                        }
                        var item = '<li item_index="' + index + '" effect_selected="' + selectedEffect + '"  id="qq-upload-item-id' + index + '" class="qq-upload-success"><span class="qq-upload-file">' + uploadItem.filename + '</span></li>';
                        $('.qq-upload-list').append(item);
                        _handler.onUploaderComplete(null, index, uploadItem.filename, uploadItem.responseJson, uploadItem.selected);
                    }
                }
            },

            syncUI : function() {

                $(".selectable").children("li").click(function(e) {
                    var defaultBrightness = $(this).attr('default_brightness');
                    var defaultContrast = $(this).attr('default_contrast');

                    $('#brightness-control').slider("value", defaultBrightness);
                    $('#contrast-control').slider("value", defaultContrast);

                    var brightnessContrast = {
                        'brightness' : defaultBrightness,
                        'contrast' : defaultContrast
                    };

                    $(".selectable").children("li").removeClass('ui-selected');
                    var imageSelected = $(this);
                    $(this).addClass('ui-selected');
                    var $img = $(this).attr('image_url');
                    var effect = $(this).attr('effect_id');
                    var crop = {};

                    if ( typeof (settings.effects[effect]) != 'undefined') {
                        var effectPrice = settings.effects[effect].price;
                        optionsPrice.addCustomPrices('image_effect', {
                            excludeTax : effectPrice,
                            includeTax : effectPrice,
                            oldPrice : effectPrice,
                            price : effectPrice,
                            priceValue : effectPrice,
                            type : "fixed"
                        });
                        optionsPrice.reload();
                    }

                    if ( typeof (_imageCrop) != 'undefined' && _imageCrop != null && typeof (_imageCrop.tellSelect()) != 'undefined') {

                        var cropArea = _imageCrop.tellSelect();

                        var imageViewerW = $('#org-image-upload-clone').width();
                        var imageViewerH = $('#org-image-upload-clone').height();
                        var imageCropW = $('#org-image-upload').width();
                        var imageCropH = $('#org-image-upload').height();

                        var dW = parseFloat(imageCropW) / parseFloat(imageViewerW);
                        var dH = parseFloat(imageCropH) / parseFloat(imageViewerH);

                        crop['x'] = parseInt(parseFloat(cropArea.x) / dW);
                        crop['y'] = parseInt(parseFloat(cropArea.y) / dH);
                        crop['w'] = parseInt(parseFloat(cropArea.w) / dW);
                        crop['h'] = parseInt(parseFloat(cropArea.h) / dH);

                        var cropSelect = [cropArea.x, cropArea.y, cropArea.x2, cropArea.y2];

                        $('#crop-select').val(cropSelect.join(','));
                    }

                    if ( typeof (imageSelected.data('imgLoad')) == 'undefined' || imageSelected.data('imgLoad') == null || imageSelected.data('imgLoad') == '') {
                        $.ajax({
                            url : PROCESS_MAIN_IMAGE_URL,
                            type : 'POST',
                            data : {
                                'image_path' : _currentImagePath,
                                'effect_id' : effect,
                                'crop' : crop,
                                'brightness_contrast' : brightnessContrast
                            },
                            dataType : 'json',
                            async : false,
                            success : function(data) {
                                imageSelected.data('imgLoad', data.src);
                                imageSelected.data('imgPathLoad', data.path);
                                _imageZoom.iviewer('loadImage', data.src);
                                if (_selectedUpload) {
                                    _selectedUpload['currentImageUrl'] = data.src;
                                }
                                $('a.share-link-button').each(function() {
                                    var linkTemplate = $(this).attr('link_template');
                                    var link = linkTemplate.replace('{ADDRESS}', encodeURIComponent(data.src)).replace('{BLOGURL}', encodeURIComponent(window.location.href)).replace('{IMAGE}', encodeURIComponent(data.src));
                                    $(this).attr('href', link);
                                });

                                $('#file-image-selected').val(data.src);
                                $('#effect-selected').val(effect);
                                _selectedImagePath = data.path;
                                $('#file-path-image-selected').val(_selectedImagePath);
                            }
                        });
                    } else {
                        _imageZoom.iviewer('loadImage', imageSelected.data('imgLoad'));
                        $('a.share-link-button').each(function() {
                            var linkTemplate = $(this).attr('link_template');
                            var link = linkTemplate.replace('{ADDRESS}', encodeURIComponent(imageSelected.data('imgLoad'))).replace('{BLOGURL}', encodeURIComponent(window.location.href)).replace('{IMAGE}', encodeURIComponent(imageSelected.data('imgLoad')));
                            $(this).attr('href', link);
                        });
                        $('#file-image-selected').val(imageSelected.data('imgLoad'));
                        $('#effect-selected').val(effect);
                        _selectedImagePath = imageSelected.data('imgPathLoad');
                        $('#file-path-image-selected').val(_selectedImagePath);
                    }

                    var itemActive = $('ul.qq-upload-list').children('li.active').attr('effect_selected', $(this).attr('id'));
                    var itemIndex = itemActive.attr('item_index');
                    if ( typeof (_uploadList[itemIndex]) == 'object') {
                        _uploadList[itemIndex].selectedEffect = $(this).attr('id');
                        $('#upload_list').val($.toJSON(_uploadList));
                    }
                });

                //REQID 15
                $('#options_14_2,#options_14_3').click(function() {
                    $('#group_option_container_9 .ui-widget-header').html('5. Edge Options');
                    $('#group_option_container_10 .ui-widget-header').html('6. Paint Texture Options');
                    $('#group_option_container_11 .ui-widget-header').html('7. Comments');
                });

                $('#options_14_4,#options_14_5,#options_14_6,#options_14_7,#options_14_8,#options_14_9').click(function() {
                    //$('#group_option_container_9 .ui-widget-header').html('Edge Options');
                    $('#group_option_container_10 .ui-widget-header').html('5. Paint Texture Options');
                    $('#group_option_container_11 .ui-widget-header').html('6. Comments');
                });

                //End REQID 15
                $('#save-effect').click(function() {
                    // Update breadcrumb menu
                    $('#custom-painting .breadcrumb li:eq(0)').find('a').removeClass('active');
                    $('#custom-painting .breadcrumb li:eq(1)').find('a').addClass('active');
                    $('#effect-container').hide();
                    //show customer painting option
                    $('#custom-painting').show();
                    $('#sub-group-option-1, #sub-group-option-3,#sub-group-option-13').hide();
                    $('h3.group-option-tooltip').each(function() {
                        $(this).qtip({
                            content : {
                                title : {
                                    text : $(this).text(),
                                    button : 'Close'
                                },
                                text : $(this).attr('description')
                            },
                            position : {
                                target : $(document.body), // Position it via the document body...
                                corner : 'center' // ...at the center of the viewport
                            },
                            show : {
                                when : 'click', // Show it on click
                                solo : true // And hide all other tooltips
                            },
                            hide : false,
                            style : {
                                width : {
                                    max : 350
                                },
                                padding : '14px',
                                border : {
                                    width : 9,
                                    radius : 9,
                                    color : '#666666'
                                },
                                name : 'light'
                            },
                            api : {
                                beforeShow : function() {
                                    // Fade in the modal "blanket" using the defined show speed
                                    $('#qtip-blanket').fadeIn(this.options.show.effect.length);
                                },
                                beforeHide : function() {
                                    // Fade out the modal "blanket" using the defined hide speed
                                    $('#qtip-blanket').fadeOut(this.options.hide.effect.length);
                                }
                            }
                        });

                    });

                    // Create the modal backdrop on document load so all modal tooltips can use it
                    $('<div id="qtip-blanket">').css({
                        position : 'absolute',
                        top : $(document).scrollTop(), // Use document scrollTop so it's on-screen even if the window is scrolled
                        left : 0,
                        height : $(document).height(), // Span the full document height...
                        width : '100%', // ...and full width

                        opacity : 0.7, // Make it slightly transparent
                        backgroundColor : 'black',
                        zIndex : 5000 // Make sure the zIndex is below 6000 to keep it below tooltips!
                    }).appendTo(document.body)// Append to the document body
                    .hide();
                    // Hide it initially

                    $('img.custom-paint-option-img').each(function() {

                        $(this).qtip({
                            content : {
                                // Set the text to an image HTML string with the correct src URL to the loading image you want to use
                                text : '<div style="float:left"><img style="width:400px;height:400px" class="throbber" src="' + $(this).attr('href') + '" alt="' + $(this).attr('alt') + '" /></div>',
                                //url: $(this).attr('href'), // Use the rel attribute of each element for the url to load
                                title : {
                                    text : $(this).attr('alt'), // Give the tooltip a title using each elements text
                                    button : 'Close' // Show a close link in the title
                                }
                            },
                            position : {
                                adjust : {
                                    screen : true // Keep the tooltip on-screen at all times
                                }
                            },

                            style : {
                                tip : true, // Apply a speech bubble tip to the tooltip at the designated tooltip corner
                                border : {
                                    width : 0,
                                    radius : 4
                                },
                                name : 'light', // Use the default light style
                                width : 420 // Set the tooltip width

                            }
                        })
                    });
                    /*
                     }
                     else{
                     alert('Please select effect');
                     }
                     */
                });

                $('#add-to-cart').click(function() {
                    if ($('#effect-selected').val() != '' && $('#file-image-selected').val() != '') {
                        productAddToCartForm.submit(this);
                    } else {
                        alert('Please upload image');
                    }
                });

                $('#back-edit-image').click(function() {
                    //$.modal.close();
                    // Update breadcrumb menu
                    $('#effect-container .breadcrumb li:eq(0)').find('a').addClass('active');
                    $('#effect-container .breadcrumb li:eq(1)').find('a').removeClass('active');
                    $('#custom-painting').hide();
                    $('#effect-container').show();
                });

                $('#share-buttons').jsShare({
                    maxwidth : 300,
                    imagePath : settings.siteUrl + 'skin/frontend/picasso/default/sm/',
                    delicious : false,
                    stumbleupon : false,
                    digg : false,
                    minwidth : 80,
                    yoursiteurl : window.location.href

                });

                $('#save-image').click(function() {
                    var urlDownload = DOWNLOAD_IMAGE_URL + "?path=" + encodeURIComponent(_selectedImagePath);
                    $('#download-frame').attr('src', urlDownload);
                });
                $('#upload-image').click(function() {
                    if ($.browser.mozilla) {
                        $('input[name="file"]').click();
                    }
                });

                $('#crop-button').click(function() {

                    if (!$('#org-image-upload').data('is_croped')) {
                        $('#org-image-upload').Jcrop({
                            onSelect : function() {
                                _handler.reloadEffect();
                            }
                        }, function() {
                            _imageCrop = this;

                        });
                        _imageCrop.release();
                        _imageCrop.disable();
                        $('#org-image-upload').data('is_croped', true);
                        $(this).data('is_crop', true);
                    }

                    if ($(this).data('is_crop')) {
                        $(this).html('Cancel Crop');
                        _imageCrop.enable();
                        $(this).data('is_crop', false);
                    } else {
                        $(this).html('Crop Image');

                        if ( typeof (_imageCrop) != 'undefined') {
                            _imageCrop.release();
                            _imageCrop.disable();
                        }
                        $(this).data('is_crop', true);
                    }

                });

                $('#brightness-control').slider({
                    from : -127,
                    to : 127,
                    step : 1,
                    round : 1,
                    format : {
                        format : '##',
                        locale : 'de'
                    },
                    dimension : '',
                    skin : "round",
                    callback : function(value) {
                        _handler.reloadEffect();
                    }
                });
                $('#contrast-control').slider({
                    from : -127,
                    to : 127,
                    step : 1,
                    round : 1,
                    format : {
                        format : '##',
                        locale : 'de'
                    },
                    dimension : '',
                    skin : "round",
                    callback : function(value) {
                        _handler.reloadEffect();
                    }
                });
                if ( typeof (settings.currentImageEdit) != 'undefined') {
                    $('#brightness-control').slider("value", settings.currentImageEdit.brightnessContrast.brightness);
                } else {
                    $('#brightness-control').slider("value", 0);
                }

                if ( typeof (settings.currentImageEdit) != 'undefined') {
                    $('#contrast-control').slider("value", settings.currentImageEdit.brightnessContrast.contrast);
                } else {
                    $('#contrast-control').slider("value", 0);
                }

                // setup crop image

                if ( typeof (settings.currentImageEdit) != 'undefined' && settings.currentImageEdit.orgImageSrc != '') {

                    $('#org-image-upload-container').html('<img style="width:100%;display:none" src="' + settings.currentImageEdit.orgImageSrc + '" id="org-image-upload"/>')
                    $('#org-image-upload-clone').attr('src', settings.currentImageEdit.orgImageSrc);
                    $('#org-image-src').val(settings.currentImageEdit.orgImageSrc);

                    $('#org-image-upload').show().attr('src', settings.currentImageEdit.orgImageSrc);

                    if ( typeof (settings.currentImageEdit.fileImageSelected) != 'undefined') {
                        _imageZoom.iviewer('loadImage', settings.currentImageEdit.fileImageSelected);
                        $('#file-image-selected').val(settings.currentImageEdit.fileImageSelected);
                        $('a.share-link-button').each(function() {
                            var linkTemplate = $(this).attr('link_template');
                            var link = linkTemplate.replace('{ADDRESS}', encodeURIComponent(settings.currentImageEdit.fileImageSelected)).replace('{BLOGURL}', encodeURIComponent(window.location.href)).replace('{IMAGE}', encodeURIComponent(settings.currentImageEdit.fileImageSelected));
                            $(this).attr('href', link);
                        });
                    }

                    if ( typeof (settings.currentImageEdit.filePathImageSelected) != 'undefined') {
                        _selectedImagePath = settings.currentImageEdit.filePathImageSelected;
                    }

                    if ( typeof (settings.currentImageEdit.effectSelected) != 'undefined') {
                        $('#image-effect-' + settings.currentImageEdit.effectSelected).addClass('ui-selected');
                    }

                    //console.log(settings.currentImageEdit.cropSelect.length);
                    /*
                     $('#org-image-upload').Jcrop({
                     onSelect:function(){
                     _handler.reloadEffect();
                     }
                     },
                     function(){
                     _imageCrop = this;

                     });
                     _imageCrop.release();
                     _imageCrop.disable();
                     */
                }

                /*
                 $('#apply-crop-button').click(function(){
                 _handler.reloadEffect();
                 });
                 */

                $('#image-editor-main-image').find('.qq-upload-button').css('box-shadow', 'none');

                // Use the each() method to gain access to each elements attributes

                $('.effect-accordion-header').live('click', function() {
                    $(this).next().slideToggle();
                    //Destroy view
                    //Init mCustomScrollbar
                    $('.image-editor-col-left').mCustomScrollbar('destroy');

                    //Re-init
                    //Init mCustomScrollbar
                    setTimeout(function() {
                        $('.image-editor-col-left').mCustomScrollbar({
                            scrollButtons : {
                                enable : true
                            },
                            theme : "light-2"

                        });
                    }, 300);
                    // Wait for update content height

                });

                $(document).bind('uploader-oncomplete', this, _handler.onUploaderComplete);

                //Init mCustomScrollbar
                $('.image-editor-col-left').mCustomScrollbar({
                    scrollButtons : {
                        enable : true
                    },
                    theme : "light-2"

                });
            }
        }, $.jsa.WidgetAbstract, settings); 
        
        
    };
    //Document is ready
    $(document).ready(function() {
        App.init(appSettings);
        $('input.product-custom-option:checked').parent().addClass('selected');
    }); 

    
})(jQuery);

function reloadImage(sender, src) {
    jQuery(sender).hide();
    if (sender.timerLoad) {
        clearInterval(sender.timerLoad);
    }
    sender.timerLoad = setInterval(function() {
        jQuery(sender).attr('src', src + '?r=' + Math.random());
    }, 3000);
}

function imageThumbLoaded(sender) {
    if (sender.timerLoad) {
        clearInterval(sender.timerLoad);
    }
    jQuery(sender).show().data('is_loaded', true);
} 

function uploadPhotoSocial(url)
{
   console.log("Image URL API" +url);
   var uploadAPI='http://dev.projectpicasso.com/picasso/upload/upload_url?url=';
   jQuery("#upload-popup").dialog('close');
    // call AJX for upload
    jQuery.get(uploadAPI+url, function( data ) {
         // App._handler.onUploaderComplete(null, 0,"",data, false);
         console.log(picassoApp);
         picassoApp.processOncompletedUploadURL(data);
      
 });

}