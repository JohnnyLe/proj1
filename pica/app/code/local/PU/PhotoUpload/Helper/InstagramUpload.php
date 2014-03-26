<?php
    require_once 'PU/PhotoUpload/Helper/BaseUpload.php';

    class InstagramUpload extends BaseUpload {

        // private $userID = '';

        /**
         * @author: htxkhoa.
         * @description: Constructor, set client ID, client secret and re-direct URL of the app from Instagram.
         */
        public function __construct() {
            $this -> clientID = INSTAGRAM_CLIENT_ID;
            $this -> clientSecret = INSTAGRAM_CLIENT_SECRET;
            $this -> redirectURI = INSTAGRAM_REDIRECT_URI;
        }

        /**
         * @author: htxkhoa.
         * @description: get access token to access user's resources.
         */
        public function getAccessToken($code) {
            $post_data = array(
                'client_id' => INSTAGRAM_CLIENT_ID,
                'client_secret' => INSTAGRAM_CLIENT_SECRET,
                'grant_type' => 'authorization_code',
                'redirect_uri' => INSTAGRAM_REDIRECT_URI,
                'code' => $code
            );

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, 'https://api.instagram.com/oauth/access_token');
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($ch, CURLOPT_POST, 1);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
            curl_setopt($ch, CURLOPT_HTTPHEADER, array('Accept: application/json'));
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

            $results = curl_exec($ch);
            curl_close($ch);

            if (curl_error($ch)) {
                return '';
            }

            if (isset($results) && $results != '') {
                $data = (array)(json_decode($results));
                Mage::getSingleton("core/session") -> setInstagramAccessToken($data['access_token']);
                Mage::getSingleton("core/session") -> setInstagramUserID($data['user'] -> id);
                $access_token = array(
                    "access_token" => $data['access_token'],
                    "user_id" => $data['user'] -> id
                );
                return $access_token;
            } else {
                return '';
            }
        }

        public function authorize() {
            header('Location:https://api.instagram.com/oauth/authorize/?client_id=' . $this -> clientID . '&redirect_uri=' . $this -> redirectURI . '&response_type=code&scope=basic+likes+comments+relationships');
            exit ;
        }

        public function getListOfAlbums($userID) {

            $access_token = Mage::getSingleton("core/session") -> getInstagramAccessToken();
            //$url = 'https://api.instagram.com/v1/media/popular?client_id=' . $this->clientID;
            $url = 'https://api.instagram.com/v1/users/' . $userID . '/media/recent/?access_token=' . $access_token;
            $curl_connection = curl_init($url);
            curl_setopt($curl_connection, CURLOPT_CONNECTTIMEOUT, 30);
            curl_setopt($curl_connection, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($curl_connection, CURLOPT_SSL_VERIFYPEER, false);

            $results = curl_exec($curl_connection);
            curl_close($curl_connection);
            return $results;
        }

        // use ajax to call this action and use jQuery to parse data.
        // Steps:
        // 1. get code from redirect uri.
        // 2. get access token from code.
        // 3. get resources of user.
        public function get_list_albums_instagram() {

            // if (isset($_GET['code']) && $_GET['code'] != '') {
            // Mage::getSingleton("core/session") -> setInstagramCode($_GET['code']);
            // }
            //
            $media_results = $this -> getListOfAlbums($userID);

            // Encode result in json format.
            // $this->getResponse()->setBody(Mage::helper('core')->jsonEncode($media_results));
            echo $media_results;
        }

        function writeLog($data) {
            // open log file
            $filename = "D://log.txt";
            $fh = fopen($filename, "w+") or die("Could not open log file.");
            fwrite($fh, date("d-m-Y, H:i") . " - $data\n") or die("Could not write file!");
            fclose($fh);
        }

    }
?>