<?php

$installer = $this;
/* @var $installer Mage_Sales_Model_Mysql4_Setup */

$installer->startSetup();
$installer->run("
ALTER TABLE  `catalog_product_option_type_value` ADD  `image` TEXT CHARACTER SET utf8 COLLATE utf8_general_ci NULL
");
$installer->endSetup();
