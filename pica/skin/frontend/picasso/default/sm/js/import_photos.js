jQuery(document).ready(function() {
   
// show popup the first time
        jQuery('#upload-image').hide();
        jQuery('#loading').hide();
        jQuery('#social').show();
        jQuery('.photo-gallery').hide();
        jQuery('#upload-popup h1').hide();
        jQuery("#upload-popup").dialog({
            autoOpen : true,
            modal : true,
            height : 600,
            width : 750,
            position : [350, 50],
            close : function() {
                //jQuery('#upload-image').show();
            }
        }).fadeIn();
        jQuery(".ui-widget-overlay").css({opacity: '0.5'});

   // click upload 
   jQuery('.qq-upload-button').click(function(e) {
        jQuery('#upload-image').hide();
        jQuery('#loading').hide();
        jQuery('#social').show();
        jQuery('.photo-gallery').hide();
        jQuery('#upload-popup h1').hide();
        jQuery("#upload-popup").dialog({
            autoOpen : true,
            modal : true,
            height : 600,
            width : 750,
            position : [350, 50],
            close : function() {
                //jQuery('#upload-image').show();
            }
        }).fadeIn();

        jQuery(".ui-widget-overlay").css({opacity: '0.5'});
    });

    jQuery('#my-computer').click(function(e) {
        pica.importPhotos('my-computer');
    });

    jQuery('#facebook').click(function(e) {
        pica.importPhotos('facebook');
    });

    jQuery('#instagram').click(function(e) {
        pica.importPhotos('instagram');
    });

    jQuery('#gplus').click(function(e) {
        pica.importPhotos('g-plus');
    });

    jQuery('#photobucket').click(function(e) {
    });

});

var isUserInstagramAuthorized = false, isUserFacebookAuthorized = false, isUserGPlusAuthorized = false, instagramResults = false, facebookResults = false, isUserHasPhoto = false;
var instagramWindow = null;

pica = {
    importPhotos : function(photoResourceType) {
        jQuery('.photo-gallery').empty();
        switch(photoResourceType) {
            case 'my-computer':
                this.importPhototsFromMyComputer();
                break;
            case 'facebook':
                this.importFacebookPhotos();
                break;
            case 'g-plus':
                this.importGooglePlusPhotos();
                break;
            case 'instagram':
                this.importInstagramPhotos();
                break;
            case 'photobucket':
                this.importPhotobucketPhotos();
                break;
            default:
                console.log("Currently the system don't support this type.");
                break;
        }
    },

    importPhototsFromMyComputer : function() {
        // Get file upload element and fire click event on it.
        document.getElementById('file-input-upload').click();
    },

    importFacebookPhotos : function() {

           var facebookWindows = window.open("http://dev.projectpicasso.com/PhotoUpload/index/authorize?type=facebook", "", "width=650,height=500,left=500");

            // Check every second to determine Instagram log in window is closed.
            var checkInterval = setInterval(function() {
                if (facebookWindows.closed) {
                    clearInterval(checkInterval);

                    jQuery('#upload-image').hide();
                    jQuery('#loading').show();
                    jQuery('#social').hide();
                    jQuery('.photo-gallery').show();
                    // Create an ajax request to get photos.
                    pica.facebookGetPhoto();
                }
            }, 1);

    },

    importGooglePlusPhotos : function() {
        // If user not authorized.
        if (isUserGPlusAuthorized == false) {
            var gplusWindow = window.open("http://dev.projectpicasso.com/PhotoUpload/index/authorize?type=gplus", "", "width=550,height=500,left=500");

            // Check every second to determine Instagram log in window is closed.
            var checkInterval = setInterval(function() {
                if (gplusWindow.closed) {
                    clearInterval(checkInterval);

                    // User is authorized.
                    isUserGPlusAuthorized = true;

                    // Create an ajax request to get photos.
                    pica.gplusGetPhoto();
                }
            }, 1);
        } else {
            // If user have already authorized, create an AJAX request to get the photos.
            this.instagramGetPhoto();
        }
    },

    importInstagramPhotos : function() {

        // If user not authorized.
         var instagramWindow = window.open("http://dev.projectpicasso.com/PhotoUpload/index/authorize?type=instagram", "", "width=550,height=500,left=500");

            // Check every second to determine Instagram log in window is closed.
            var checkInterval = setInterval(function() {
                if (instagramWindow != null && instagramWindow.closed) {
                    clearInterval(checkInterval);
                    jQuery('#upload-image').hide();
                    jQuery('#loading').show();
                    jQuery('#social').hide();
                    jQuery('.photo-gallery').show();
                    // Create an ajax request to get photos.
                    pica.instagramGetPhoto();
                }
            }, 1);

    },

    instagramGetPhoto : function() {

        jQuery.ajax({
            type : "GET",
            url : "http://dev.projectpicasso.com/PhotoUpload/index/get_photos_from_instagram",
            success : function(data) {
                jQuery('#loading').hide();
                jQuery('#upload-popup h1').show();

                var result = jQuery.parseJSON(data);
                console.log(result);

                //Instagram limits to max 20, but you can do less for your layout.
                var numberToDisplay = result.data.length;

                for (var i = 0; i < numberToDisplay; i++) {
                    // htxuankhoa - integrate with existed module.
                    var imageURL=result.data[i].images.standard_resolution.url;
                    jQuery(".photo-gallery").append("<a href='#' onClick='uploadPhotoSocial(\""+imageURL+"\")'><img class='social-image' src='" + imageURL + "'/></a>"); 

                }
            },
            error : function(textStatus, errorThrown) {
                jQuery('#loading').hide();
                console.log('error: ' + textStatus);
            }
        });

    },

    gplusGetPhoto : function() {

        jQuery.ajax({
            type : "GET",
            url : "http://dev.projectpicasso.com/PhotoUpload/index/get_photos_from_gplus",
            success : function(data) {
                console.log('success: ' + data);
                var result = jQuery.parseJSON(data);

                console.log(result);

                //Instagram limits to max 20, but you can do less for your layout.
                var numberToDisplay = 20;

                // console.log(result.data[0].images.standard_resolution);

                for (var i = 0; i < numberToDisplay; i++) {
                    jQuery(".photo-gallery").append("<div class='instagram-placeholder'><a target='_blank' href='http://dev.projectpicasso.com/PhotoUpload/index/upload?type=instagram&url=" + result.data[i].images.standard_resolution.url + "'><img class='instagram-image' src='" + result.data[i].images.thumbnail.url + "' /></a></div>");
                }
            },
            error : function(textStatus, errorThrown) {
                console.log('error: ' + textStatus);
            }
        });

    },

    facebookGetPhoto : function() {

        jQuery.ajax({
            type : "GET",
            url : "http://dev.projectpicasso.com/PhotoUpload/index/get_photos_from_facebook",
            success : function(data) {
                jQuery('#loading').hide();
                jQuery('#upload-popup h1').show();
                var result = jQuery.parseJSON(data);
                //console.log("get photo from facebook response:");
                //Facebook limits to max 20, but you can do less for your layout.
                var numberToDisplay = result[0].length;
                for (var i = 0; i < numberToDisplay; i++) {
                    // htxuankhoa - integrate with existed module.
                     //console.log(result[0][i].images);
                     var uploadAPI='http://dev.projectpicasso.com/picasso/upload/upload_url?url=';
                     var imageURL=result[0][i].images[2].source;
                     uploadAPI=uploadAPI+imageURL;
                     jQuery(".photo-gallery").append("<a href='#' onClick='uploadPhotoSocial(\""+imageURL+"\")'><img class='social-image' src='" + imageURL + "' /></a>"); 
              
                }
            },
            error : function(textStatus, errorThrown) {
                console.log('error: ' + textStatus);
            }
        });

    },

    importPhotobucketPhotos : function() {
        console.log('Import Photobucket photos.');
    }
};



function uploadPhotoSocial(url)
{
   console.log("Image URL API" +url);
   var uploadAPI='http://dev.projectpicasso.com/picasso/upload/upload_url?url=';
   jQuery("#upload-popup").dialog('close');
    // call AJX for upload
    jQuery.get(uploadAPI+url, function( data ) {
         // App._handler.onUploaderComplete(null, 0,"",data, false);
        var filename=GetFilename(url);
        var dataResponse=jQuery.parseJSON(data);
        jQuery(document).trigger('uploader-oncomplete', [0,filename,dataResponse]);
      
 });

}


function GetFilename(url)
{
   if (url)
   {
      var m = url.toString().match(/.*\/(.+?)\./);
      if (m && m.length > 1)
      {
         return m[1];
      }
   }
   return "";
}