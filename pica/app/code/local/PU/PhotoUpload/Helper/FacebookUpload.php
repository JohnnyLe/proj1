<?php
require_once 'BaseUpload.php';
require_once 'CommonConstants.php';
require_once 'PU/PhotoUpload/Helper/facebook_sdk/facebook.php';

class  FacebookUpload extends BaseUpload {
    private $user_id = 0;
    private $facebook = null;

    /**
     * @author: Khoa Hoang.
     * @description: Constructor, set client ID, client secret and re-direct URL of the app from Facebook.
     */
    public function __construct() {
        $this -> clientID = FACEBOOK_CLIENT_ID;
        $this -> clientSecret = FACEBOOK_CLIENT_SECRET;
        $this -> redirectURI = FACEBOOK_REDIRECT_URI;

        // Initialize configuration array.
        $config = array(
            'appId' => FACEBOOK_CLIENT_ID,
            'secret' => FACEBOOK_CLIENT_SECRET
        );

        //  $config = array(
        //     'appId' => FACEBOOK_CLIENT_ID,
        //     'secret' => FACEBOOK_CLIENT_SECRET,
        //     'cookie' => true,
        //     'fileUpload' => false,
        //     'allowSignedRequest' => false,
        // );

        // Initialize Facebook connection object.
        $this -> facebook = new Facebook($config);
    }

    public function getUser() {
        return $this -> facebook -> getUser();
    }

    /**
     * @author: Khoa Hoang.
     * @description: Authorize Facebook user with our application.
     */
    public function authorize() {
        try {
            // If user is still not connected (not log in) to Facebook, re-direct user to Facebook log in page.
            if ($this -> facebook -> getUser() == 0) {
                // die("facebook initialized.");

                header('Location:' . $this -> facebook -> getLoginUrl(array(
                 'scope' => 'user_photos',
                 'redirect_uri' => $this -> redirectURI
                )));

                // After user have logged on to facebook, facebook api will redirect user to the previous page user is standing with code.
                // In this case, this URL is: pical.loca/authorize.
                //header('Location:' . $this -> facebook -> getLoginUrl());
                exit ;
            }
        } catch(Exception $e) {

            die("Facebook not initialized.");

        }

    }

    /**
     * @author: Khoa Hoang.
     * @description: get list albums of specific user. AJAX
     */
    public function getListOfAlbums($userID) {
        $list_of_photos = array();

        // Get user's profile and user's photos.
        try {
            $userID = $this -> facebook -> getUser();
            
            if ($userID != 0) {

                // Get user's profile to get user id.
                // $user_profile = $this -> facebook -> api('/me');

                // Get list of albums.
                $albums = $this -> facebook -> api('/me/albums');

                $tempPhoto='';
                foreach ($albums['data'] as $album) {
                    $photos = $this -> facebook -> api('/' . $album['id'] . '/photos');
                    foreach ($photos as $photo) {
                        array_push($list_of_photos, $photo);
                        $tempPhoto=$tempPhoto . $photo;
                    }
                }
            } else {
                echo json_encode("user dont have value.");
                exit ;
            }

        } catch(Exception $e) {
            $this -> writeLog('EXCEPTION: Can not use facebook connection api. ' . $e -> getMessage());
            echo json_encode(array("user_profile" => $user_profile));
            exit ;
        }
        
        $this -> writeLog('get list photo ... userID ' . $userID . '| photo' . $tempPhoto . '| albums' . $albums);
        return $list_of_photos;
    }

    public function writeLog($data) {
        // open log file
        $filename = "PU_Facebook_log.txt";
        $fh = fopen($filename, "w+") or die("Could not open log file.");
        fwrite($fh, date("d-m-Y, H:i") . " - $data\n") or die("Could not write file!");
        fclose($fh);
    }

}
?>