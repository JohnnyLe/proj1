<?php
$installer = $this;

$installer->startSetup();

$installer->run("
ALTER TABLE  `catalog_product_option` ADD  `custom_option_depend` VARCHAR( 255 ) NULL
");

$installer->endSetup();