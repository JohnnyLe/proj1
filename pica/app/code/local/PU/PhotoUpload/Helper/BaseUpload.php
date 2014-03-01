<?php
    abstract class  BaseUpload {
        protected $clientID;
        protected $clientSecret;
        protected $redirectURI;
        protected $accessToken;
        protected $code;

        abstract public function authorize();
        abstract public function getListOfAlbums($userID);
        // abstract public function getSpecificPhoto($photoURL);
        public function upload($photoURL) {
            try {
                if (!isset($photoURL) || $photoURL == '') {
                    return false;
                }

                //desitnation directory
                $path = Mage::getBaseDir() . DS . 'media/photo_upload';

                // trim file name from the URL
                $filename = array_pop(explode('/', $photoURL));

                $image = file_get_contents($photoURL);
                file_put_contents($path . '/' . $filename, $image);

                return true;
            } catch (Exception $e) {
                return false;
            }
        }

    }
?>