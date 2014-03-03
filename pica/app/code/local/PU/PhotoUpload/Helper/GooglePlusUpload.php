<?php
    require_once 'BaseUpload.php';
    require_once 'CommonConstants.php';
    require_once 'google_plus_sdk/Google_Client.php';
    require_once 'google_plus_sdk/service/Google_Service.php';
    require_once 'google_plus_sdk/contrib/Google_PlusService.php';

    class  GooglePlusUpload extends BaseUpload {
        private $developer_key = '';
        private $google_client = null;
        private $google_plus = null;

        /**
         * @author: Khoa Hoang.
         * @description: Constructor, set client ID, client secret, re-direct URI and developer key of the app from Google Plus.
         */
        public function __construct() {

            $this -> clientID = GOOGLEPLUS_CLIENT_ID;
            $this -> clientSecret = GOOGLEPLUS_CLIENT_SECRET;
            $this -> redirectURI = GOOGLEPLUS_REDIRECT_URI;
            $this -> developer_key = GOOGLEPLUS_DEVELOPER_KEY;

            $this -> google_client = new Google_Client();
            $this -> google_client -> setClientId(GOOGLEPLUS_CLIENT_ID);
            $this -> google_client -> setClientSecret(GOOGLEPLUS_CLIENT_SECRET);
            $this -> google_client -> setRedirectUri(GOOGLEPLUS_REDIRECT_URI);
            $this -> google_client -> setDeveloperKey(GOOGLEPLUS_DEVELOPER_KEY);

            $this -> google_plus = new Google_PlusService($this -> google_client);

        }

        /**
         * @author: Khoa Hoang.
         * @description: Authorize Google Plus user with our application.
         */
        public function authorize() {

            if (!$this -> google_client -> getAccessToken()) {
                $auth_url = $this -> google_client -> createAuthUrl();
                if (isset($auth_url) && $auth_url != '') {
                    header('Location:' . $auth_url);
                    exit ;
                }
            }
        }

        function writeLog($data) {
            // open log file
            $filename = "D://log.txt";
            $fh = fopen($filename, "w+") or die("Could not open log file.");
            fwrite($fh, date("d-m-Y, H:i") . " - $data\n") or die("Could not write file!");
            fclose($fh);
        }

        public function getListOfAlbums($userID) {
            try {
                $me = $this -> google_plus -> people -> get('me');
                $id = filter_var($me['id'], FILTER_VALIDATE_URL);
                $this -> writeLog('ID : ' . $id);
                return;
            } catch(Exception $e) {
                $this -> writeLog('Error : ' . $e -> getMessage());
            }

        }

        // public function getSpecificPhoto($photoURL){
        // }

        // public function upload($photoURL){
        // }
    }
?>