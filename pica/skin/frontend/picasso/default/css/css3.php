<?php
    header('Content-type: text/css; charset: UTF-8');
    header('Cache-Control: must-revalidate');
    header('Expires: ' . gmdate('D, d M Y H:i:s', time() + 3600) . ' GMT');
    $url = $_REQUEST['url'];
?>
.picasso-toolbar #save-image,
.picasso-toolbar #close-image , #save-effect , .picasso-toolbar #share-buttons,
#upload-image  {behavior: url(<?php echo $url; ?>css/css3.htc);position:relative;}

