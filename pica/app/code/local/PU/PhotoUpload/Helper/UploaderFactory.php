<?php
    require_once 'BaseUpload.php';
    require_once 'MyComputerUpload.php';
    require_once 'InstagramUpload.php';
    require_once 'FacebookUpload.php';
    require_once 'GooglePlusUpload.php';
    require_once 'CommonConstants.php';

    class UploaderFactory {
        public static function factory($type = '') {
            switch ($type) {
                case MY_COMPUTER :
                    return new MyComputerUpload();
                case INSTAGRAM :
                    return new InstagramUpload();
                case FACEBOOK :
                    return new FacebookUpload();
                case GOOGLE_PLUS :
                    return new GooglePlusUpload();
                default :
                    return null;
            }
        }

    }
?>