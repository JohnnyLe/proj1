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
                'secret' => FACEBOOK_CLIENT_SECRET,
                'cookie' => true,
                'fileUpload' => false,
                'allowSignedRequest' => false,
            );

            // Initialize Facebook connection object.
            $this -> facebook = new Facebook($config);
        }

        /**
         * @author: Khoa Hoang.
         * @description: Authorize Facebook user with our application.
         */
        public function authorize() {

            // If user is still not connected (not log in) to Facebook, re-direct user to Facebook log in page.
            if ($this -> facebook -> getUser() == 0) {
                // header('Location:' . $this -> facebook -> getLoginUrl(array(
                // 'scope' => 'email,offline_access,publish_stream,user_birthday,user_location,user_work_history,user_about_me,user_hometown',
                // 'redirect_uri' => $fbconfig['baseurl']
                // )));

                header('Location:' . $this -> facebook -> getLoginUrl());
                exit ;
            }
        }

        /**
         * @author: Khoa Hoang.
         * @description: get list albums of specific user.
         */
        public function getListOfAlbums($userID) {
            $list_of_photos = array();

            // Get user's profile and user's photos.
            try {
                $user = $this -> facebook -> getUser();

                // Get user's profile to get user id.
                $user_profile = $this -> facebook -> api('/me');

                // Get list of albums.
                $albums = $this -> facebook -> api('/me/albums');
                foreach ($albums['data'] as $album) {
                    $photos = $this -> facebook -> api('/' . $album['id'] . '/photos');
                    foreach ($photos as $photo) {
                        array_push($list_of_photos, $photo);
                    }
                }

            } catch(Exception $e) {
                $this -> writeLog('Can not use facebook connection api. ' . $e -> getMessage());
            }

            return $list_of_photos;
        }

        public function writeLog($data) {
            // open log file
            $filename = "D://log.txt";
            $fh = fopen($filename, "w+") or die("Could not open log file.");
            fwrite($fh, date("d-m-Y, H:i") . " - $data\n") or die("Could not write file!");
            fclose($fh);
        }

    }
?>