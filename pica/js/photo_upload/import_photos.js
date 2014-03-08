$(document).ready(function() {
    // Handle event for my computer upload type.
    $("#file-input-upload").change(function() {
        // If file upload change value, display window alert to ask user want to upload this file.
        var result = confirm("Do you want to upload this file to your gallery?");

        // If user pressed OK button.
        if (result == true) {
            // Get file upload element and fire click event on it.
            document.getElementById('form-my-computer-upload').submit();
        } else {
            alert("You have cancelled upload file.");

            // Clear current value of file upload control.
            $(this).val('');
        }
    });

    $('#upload-image').click(function(e) {
        $('#upload-image').hide();
        // $('#upload-image').remove();
        // $('.photo-gallery').hide();
        $('#loading').hide();
        $("#upload-popup").dialog({
            autoOpen : true,
            modal : true,
            height : 600,
            width : 850,
            position: [350, 50],
            close : function() {
                $('#upload-image').show();
            }
        }).fadeIn();
    });

    $('#my-computer').click(function(e) {
        // console.log('my computer was clicked...');
        pica.importPhotos('my-computer');
    });

    $('#facebook').click(function(e) {
        // console.log('facebook was clicked...');
        pica.importPhotos('facebook');
    });

    $('#instagram').click(function(e) {
        // console.log('instagram was clicked...');
        pica.importPhotos('instagram');
    });

    $('#gplus').click(function(e) {
        // console.log('google plus was clicked...');
        pica.importPhotos('g-plus');
    });

    $('#photobucket').click(function(e) {
        console.log('photobucket was clicked...');
    });

});

var isUserInstagramAuthorized = false, isUserFacebookAuthorized = false, isUserGPlusAuthorized = false, instagramResults = false, facebookResults = false, isUserHasPhoto = false;
var instagramWindow;
pica = {
    importPhotos : function(photoResourceType) {
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
            var facebookWindows = window.open("http://pica.local/index.php/PhotoUpload/index/authorize?type=facebook", "", "width=550,height=500,left=500");

            // Check every second to determine Instagram log in window is closed.
            var checkInterval = setInterval(function() {
                if (facebookWindows.closed) {
                    clearInterval(checkInterval);

                    $('#upload-image').hide();
                    $('#social').hide();
                    // $("#upload-popup").dialog('close');
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
            var gplusWindow = window.open("http://pica.local/index.php/PhotoUpload/index/authorize?type=gplus", "", "width=550,height=500,left=500");

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
            var instagramWindow = window.open("http://pica.local/index.php/PhotoUpload/index/authorize?type=instagram", "", "width=550,height=500,left=500");

            // Check every second to determine Instagram log in window is closed.
            var checkInterval = setInterval(function() {
                if (instagramWindow.closed) {
                    clearInterval(checkInterval);
                    $('#upload-image').hide();
                    $('.loading').show();
                    console.log($('#loading'));
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
            url : "http://pica.local/index.php/PhotoUpload/index/get_photos_from_instagram",
            success : function(data) {
                // console.log(data);

                // console.log('success: ' + data);
                var result = $.parseJSON(data);

$('#loading').hide();

                //Instagram limits to max 20, but you can do less for your layout.
                var numberToDisplay = result.data.length;

                for (var i = 0; i < numberToDisplay; i++) {
                    // $(".photo-gallery").append("<div class='instagram-placeholder'><a target='_blank' href='http://pica.local/index.php/PhotoUpload/index/upload?type=instagram&url=" + result.data[i].images.standard_resolution.url + "'><img class='instagram-image' src='" + result.data[i].images.thumbnail.url + "' /></a></div>");
                    $(".photo-gallery").append("<a target='_blank' href='http://pica.local/index.php/PhotoUpload/index/upload?type=instagram&url=" + result.data[i].images.standard_resolution.url + "'><img class='instagram-image' src='" + result.data[i].images.thumbnail.url + "' /></a>");
                }
            },
            error : function(textStatus, errorThrown) {
                console.log('error: ' + textStatus);
            }
        });

    },

    gplusGetPhoto : function() {

        $.ajax({
            type : "GET",
            url : "http://pica.local/index.php/PhotoUpload/index/get_photos_from_gplus",
            success : function(data) {
                console.log('success: ' + data);
                var result = $.parseJSON(data);

                console.log(result);

                //Instagram limits to max 20, but you can do less for your layout.
                var numberToDisplay = 20;

                // console.log(result.data[0].images.standard_resolution);

                for (var i = 0; i < numberToDisplay; i++) {
                    $(".photo-gallery").append("<div class='instagram-placeholder'><a target='_blank' href='http://pica.local/index.php/PhotoUpload/index/upload?type=instagram&url=" + result.data[i].images.standard_resolution.url + "'><img class='instagram-image' src='" + result.data[i].images.thumbnail.url + "' /></a></div>");
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
            url : "http://pica.local/index.php/PhotoUpload/index/get_photos_from_facebook",
            success : function(data) {
                console.log('success: ' + data);
                var result = $.parseJSON(data);

                //console.log(result);

                //Instagram limits to max 20, but you can do less for your layout.
                var numberToDisplay = result.data.length;

                // console.log(result.data[0].images.standard_resolution);

                for (var i = 0; i < numberToDisplay; i++) {
                    $(".photo-gallery").append("<div class='instagram-placeholder'><a target='_blank' href='http://pica.local/index.php/PhotoUpload/index/upload?type=facebook&url=" + result.data[i].source + "'><img class='instagram-image' src='" + result.data[i].images[2].source + "' /></a></div>");
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
