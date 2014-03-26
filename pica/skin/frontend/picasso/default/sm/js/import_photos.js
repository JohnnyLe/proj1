$(document).ready(function() {
    // Handle event for my computer upload type.
    $("#file-input-upload").change(function() {
        // htxuankhoa - integrate with existed module.
        qq.extend();
        qq.FileUploaderBasic.prototype._uploadFileList(document.getElementById('file-input-upload').files);
        return;



        // If file upload change value, display window alert to ask user want to upload this file.
        //var result = confirm("Do you want to upload this file to your gallery?");

        // If user pressed OK button.
        //if (result == true) {
            // Get file upload element and fire click event on it.
        //    document.getElementById('form-my-computer-upload').submit();
        //} else {
        //    alert("You have cancelled upload file.");

            // Clear current value of file upload control.
        //    $(this).val('');
        //}
    });

    $('#upload-image').click(function(e) {
        $('#upload-image').hide();
        $('#loading').hide();
        $('#social').show();
        $('.photo-gallery').hide();
        $('#upload-popup h1').hide();
        $("#upload-popup").dialog({
            autoOpen : true,
            modal : true,
            height : 600,
            width : 850,
            position : [350, 50],
            close : function() {
                $('#upload-image').show();
            }
        }).fadeIn();
    });

    $('#my-computer').click(function(e) {
        pica.importPhotos('my-computer');
    });

    $('#facebook').click(function(e) {
        pica.importPhotos('facebook');
    });

    $('#instagram').click(function(e) {
        pica.importPhotos('instagram');
    });

    $('#gplus').click(function(e) {
        pica.importPhotos('g-plus');
    });

    $('#photobucket').click(function(e) {
    });

});

var isUserInstagramAuthorized = false, isUserFacebookAuthorized = false, isUserGPlusAuthorized = false, instagramResults = false, facebookResults = false, isUserHasPhoto = false;
var instagramWindow = null;

pica = {
    importPhotos : function(photoResourceType) {
        $('.photo-gallery').empty();
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

        if (isUserFacebookAuthorized == false) {
            var facebookWindows = window.open("http://pica.local/PhotoUpload/index/authorize?type=facebook", "", "width=550,height=500,left=500");

            // Check every second to determine Instagram log in window is closed.
            var checkInterval = setInterval(function() {
                if (facebookWindows.closed) {
                    clearInterval(checkInterval);

                    $('#upload-image').hide();
                    $('#loading').show();
                    $('#social').hide();
                    $('.photo-gallery').show();

                    // User is authorized.
                    isUserFacebookAuthorized = true;

                    // Create an ajax request to get photos.
                    pica.facebookGetPhoto();
                }
            }, 1);
        } else {
            // If user have already authorized, create an AJAX request to get the photos.
            this.facebookGetPhoto();
        }

    },

    importGooglePlusPhotos : function() {
        // If user not authorized.
        if (isUserGPlusAuthorized == false) {
            var gplusWindow = window.open("http://pica.local/PhotoUpload/index/authorize?type=gplus", "", "width=550,height=500,left=500");

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
        if (isUserInstagramAuthorized == false) {
            var instagramWindow = window.open("http://pica.local/PhotoUpload/index/authorize?type=instagram", "", "width=550,height=500,left=500");

            // Check every second to determine Instagram log in window is closed.
            var checkInterval = setInterval(function() {
                if (instagramWindow != null && instagramWindow.closed) {
                    clearInterval(checkInterval);
                    $('#upload-image').hide();
                    $('#loading').show();
                    $('#social').hide();
                    $('.photo-gallery').show();

                    // User is authorized.
                    isUserInstagramAuthorized = true;

                    // Create an ajax request to get photos.
                    pica.instagramGetPhoto();
                }
            }, 1);
        } else {
            // If user have already authorized, create an AJAX request to get the photos.
            this.instagramGetPhoto();
        }

    },

    instagramGetPhoto : function() {

        $.ajax({
            type : "GET",
            url : "http://pica.local/PhotoUpload/index/get_photos_from_instagram",
            success : function(data) {
                $('#loading').hide();
                $('#upload-popup h1').show();

                var result = $.parseJSON(data);
                console.log(result);

                //Instagram limits to max 20, but you can do less for your layout.
                var numberToDisplay = result.data.length;

                for (var i = 0; i < numberToDisplay; i++) {
                    // htxuankhoa - integrate with existed module.
                    $(".photo-gallery").append("<a target='_blank' href='http://pica.local/picasso/upload?qqfile=" + result.data[i].images.standard_resolution.url + "'><img class='instagram-image' src='" + result.data[i].images.thumbnail.url + "' /></a>");

                    // $(".photo-gallery").append("<div class='instagram-placeholder'><a target='_blank' href='http://pica.local/PhotoUpload/index/upload?type=instagram&url=" + result.data[i].images.standard_resolution.url + "'><img class='instagram-image' src='" + result.data[i].images.thumbnail.url + "' /></a></div>");
                    //$(".photo-gallery").append("<a target='_blank' href='http://pica.local/PhotoUpload/index/upload?type=instagram&url=" + result.data[i].images.standard_resolution.url + "'><img class='instagram-image' src='" + result.data[i].images.thumbnail.url + "' /></a>");
                }
            },
            error : function(textStatus, errorThrown) {
                $('#loading').hide();
                console.log('error: ' + textStatus);
            }
        });

    },

    gplusGetPhoto : function() {

        $.ajax({
            type : "GET",
            url : "http://pica.local/PhotoUpload/index/get_photos_from_gplus",
            success : function(data) {
                console.log('success: ' + data);
                var result = $.parseJSON(data);

                console.log(result);

                //Instagram limits to max 20, but you can do less for your layout.
                var numberToDisplay = 20;

                // console.log(result.data[0].images.standard_resolution);

                for (var i = 0; i < numberToDisplay; i++) {
                    $(".photo-gallery").append("<div class='instagram-placeholder'><a target='_blank' href='http://pica.local/PhotoUpload/index/upload?type=instagram&url=" + result.data[i].images.standard_resolution.url + "'><img class='instagram-image' src='" + result.data[i].images.thumbnail.url + "' /></a></div>");
                }
            },
            error : function(textStatus, errorThrown) {
                console.log('error: ' + textStatus);
            }
        });

    },

    facebookGetPhoto : function() {

        $.ajax({
            type : "GET",
            url : "http://pica.local/PhotoUpload/index/get_photos_from_facebook",
            success : function(data) {
                $('#loading').hide();
                $('#upload-popup h1').show();

                var result = $.parseJSON(data);
                // console.log(result);
                // console.log(result[0][0].images[2]);

                //Facebook limits to max 20, but you can do less for your layout.
                var numberToDisplay = result[0].length;

                // console.log(result.data[0].images.standard_resolution);

                for (var i = 0; i < numberToDisplay; i++) {
                    // htxuankhoa - integrate with existed module.
                    $(".photo-gallery").append("<a target='_blank' href='http://pica.local/picasso/upload?qqfile=" + result[0][i].source + "'><img class='instagram-image' src='" + result[0][i].images[2].source + "' /></a>");

                    //$(".photo-gallery").append("<a target='_blank' href='http://pica.local/PhotoUpload/index/upload?type=facebook&url=" + result[0][i].source + "'><img class='instagram-image' src='" + result[0][i].images[2].source + "' /></a>");
                    // $(".photo-gallery").append("<div class='instagram-placeholder'><a target='_blank' href='http://pica.local/PhotoUpload/index/upload?type=facebook&url=" + result.data[i].source + "'><img class='instagram-image' src='" + result.data[i].images[2].source + "' /></a></div>");
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
