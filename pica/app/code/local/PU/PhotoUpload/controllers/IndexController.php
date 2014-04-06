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
            $this -> _redirect('index.php/PhotoUpload/index');
        } else {
            echo 'There something wrong. Please try again.';
        }

    }

    private function autoCloseWindow() {
        // Auto close current window.
        echo '<script type="text/javascript">';
        echo 'window.close();';
        echo '</script>';
        return;

    }

    public function authorizeAction() {
        $type = $_GET['type'];

        // If user have already logged in facebook.
        if (isset($_GET['code']) && !empty($_GET['code']) && isset($type) && !empty($type)) {
            $facebook = new FacebookUpload();

            // You must call this method when facebook return code after user logged in.
            $userID = $facebook -> getUser();
            if ($type == 'facebook') {
                // Save facebook code to session.
                Mage::getSingleton("core/session") -> setFacebookCode($_GET['code']);
                $this ->  writeLog('authenticated facebook' . $facebook -> getUser());
            }

            $this -> autoCloseWindow();

        }

        // Get facebook code from store's session. User logged in, not get code from facebook again.
        // Lan dau tra ve code sau do goi getUser no se tra ve user id, nhung lan sau no se khong tra ve code nua vi da authorize roi.
        if ($type == 'facebook')
        {    
          $facebook_code = Mage::getSingleton("core/session") -> getFacebookCode();
           if (isset($facebook_code) && !empty($facebook_code)) {
             $this -> autoCloseWindow();
          }
        }
        if ($type == 'instagram')
        {    
               $instagram = new InstagramUpload();
               $instagram -> authorize();
        }
        if (!isset($type) || empty($type)) {
            return json_encode(array("error" => "Type not null"));
        }

        // Initialize a specific provider.
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

        $this -> autoCloseWindow();
    }

    // BUG: instagram access token will expired but Magento session still store.
    public function get_photos_from_instagramAction() {

        $instagram = new InstagramUpload();
        $code = Mage::getSingleton("core/session") -> getInstagramCode();
        $access_token = $instagram -> getAccessToken($code);
        $userID = $access_token['user_id'];
        $media_resources = $instagram -> getListOfAlbums($userID);

        // Return array, not json.
        echo $media_resources;
        return;

    }

    // Ajax call.
    public function get_photos_from_facebookAction() {
        $facebook = new FacebookUpload();
        $list_of_photos = $facebook -> getListOfAlbums(null);
        echo json_encode($list_of_photos);
        return;

    }

    public function gplus_redirect_uriAction() {

        // Store code is got from Instagram in session.
        if (isset($_GET['code']) && $_GET['code'] != '') {
            Mage::getSingleton("core/session") -> setGPlusCode($_GET['code']);
        }

        $this -> autoCloseWindow();

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
        $filename = "PU_Index_log.txt";
        $fh = fopen($filename, "w+") or die("Could not open log file.");
        fwrite($fh, date("d-m-Y, H:i") . " - $data\n") or die("Could not write file!");
        fclose($fh);
    }

}
?>
