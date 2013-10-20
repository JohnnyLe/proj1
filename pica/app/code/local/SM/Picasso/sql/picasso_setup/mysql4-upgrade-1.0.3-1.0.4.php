<?php
$installer = $this;

$installer->startSetup();

$installer->run("
ALTER TABLE  `catalog_product_option` ADD  `group` VARCHAR( 255 ) NULL
");

$installer->endSetup();