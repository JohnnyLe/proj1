<?php
    require_once 'PU/PhotoUpload/Helper/UploaderFactory.php';

    class PU_PhotoUpload_IndexController extends Mage_Core_Controller_Front_Action {

        /**
         * @author: Khoa Hoang.
         * @description: index action for PhotoUpload controller.
         */
        public function indexAction() {

            // Load layout.
            $this -> loadLayout();
            $this -> renderLayout();

        }

        /**
         * @author: Khoa Hoang.
         * @description: upload action for PhotoUpload controller.
         */
        public function uploadAction() {

            // Get upload type and photo URL.
            $type = $_GET['type'];
            $url = $_GET['url'];

            if (!isset($type) || $type == '') {
                return;
            }

            // Initialize uploader.
            $myUploader = UploaderFactory::factory($type);

            if (!isset($myUploader) || $myUploader == null) {
                return;
            }

            if ($myUploader -> upload($url) == true) {
                $this -> _redirect('*/*/index');
            } else {
                echo 'There something wrong. Please try again.';
            }

        }

        public function authorizeAction() {
            $type = $_GET['type'];

            if (isset($_GET['code']) && !empty($_GET['code']) && isset($type) && !empty($type)) {
                if ($type == 'facebook') {
                    Mage::getSingleton("core/session") -> setFacebookCode($_GET['code']);
                }

                // Auto close current window.
                echo '<script type="text/javascript">';
                echo 'window.close();';
                echo '</script>';
                return;
            }

            $facebook_code = Mage::getSingleton("core/session") -> getFacebookCode();
            if (isset($facebook_code) && !empty($facebook_code)) {
                // Auto close current window.
                echo '<script type="text/javascript">';
                echo 'window.close();';
                echo '</script>';
                return;
            }

            if (!isset($type) || empty($type)) {
                return json_encode(array("error" => "Type not null"));
            }

            $provider = UploaderFactory::factory($type);
            if (!isset($provider) || empty($provider)) {
                return;
            }

            return $provider -> authorize();
        }

        public function instagram_redirect_uriAction() {

            // Store code is got from Instagram in session.
            if (isset($_GET['code']) && $_GET['code'] != '') {
                Mage::getSingleton("core/session") -> setInstagramCode($_GET['code']);
            }

            // Auto close current window.
            echo '<script type="text/javascript">';
            echo 'window.close();';
            echo '</script>';
        }

        public function get_photos_from_instagramAction() {

            $instagram = new InstagramUpload();
            $code = Mage::getSingleton("core/session") -> getInstagramCode();
            $access_token = $instagram -> getAccessToken($code);
            $userID = $access_token['user_id'];
            $media_resources = $instagram -> getListOfAlbums($userID);
            echo $media_resources;
            // echo json_encode($media_resources);
            return;

        }

        public function get_photos_from_facebookAction() {

            $facebook = new FacebookUpload();
            $list_of_photos = $facebook -> getListOfAlbums(null);
            echo $list_of_photos;
            return;

        }

        public function gplus_redirect_uriAction() {

            // Store code is got from Instagram in session.
            if (isset($_GET['code']) && $_GET['code'] != '') {
                Mage::getSingleton("core/session") -> setGPlusCode($_GET['code']);
            }

            // Auto close current window.
            echo '<script type="text/javascript">';
            echo 'window.close();';
            echo '</script>';

        }

        public function get_photos_from_gplusAction() {
            $code = Mage::getSingleton("core/session") -> getGPlusCode();
            //echo json_encode(array("status" => "ok", 'code' => $code));
            //return;
            $gplus = new GooglePlusUpload();
            //$code = Mage::getSingleton('core/session') -> getFacebookCode();
            //$user_id = $gplus -> getUserID();
            $list_of_photos = $gplus -> getListOfAlbums(null);
            echo json_encode($list_of_photos);
            return;

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