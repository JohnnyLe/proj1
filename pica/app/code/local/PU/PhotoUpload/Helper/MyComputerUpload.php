<?php
    require_once 'PU/PhotoUpload/Helper/BaseUpload.php';
    require_once 'PU/PhotoUpload/Helper/CommonConstants.php';

    class  MyComputerUpload extends BaseUpload {
        public function authorize() {
        }

        public function getListOfAlbums($userID) {
        }

        /**
         * @author: Khoa Hoang.
         * @description: upload photo to specific directory in the server.
         */
        public function upload($photoURL) {

            if (isset($_FILES['file-input-upload']['name']) && $_FILES['file-input-upload']['name'] != '') {
                try {
                    // Set desitnation directory.
                    $path = Mage::getBaseDir() . DS . UPLOAD_DIRECTORY;

                    // Get file name.
                    $file_name = $_FILES['file-input-upload']['name'];

                    // Load Varien_File_Uploader class of Magento.
                    $uploader = new Varien_File_Uploader('file-input-upload');

                    // Allowed extensions for file.
                    $uploader -> setAllowedExtensions(array(
                        'jpg',
                        'jpeg',
                        'gif',
                        'png'
                    ));

                    // Creating the directory if not exists.
                    $uploader -> setAllowCreateFolders(true);

                    // If true, uploaded file's name will be changed, if file with the same name already exists directory.
                    $uploader -> setAllowRenameFiles(false);
                    $uploader -> setFilesDispersion(false);

                    // Save the file on the specified path.
                    $uploader -> save($path, $file_name);

                    return true;
                } catch (Exception $e) {
                    return false;
                }
            }
            return false;

        }

    }
?>