<?php
$installer = $this;

$installer->startSetup();

$installer->run("
    ALTER TABLE  {$this->getTable('picasso/group_option')} ADD  `option_ids` VARCHAR( 555 ) NULL;
	ALTER TABLE  {$this->getTable('picasso/group_option')} ADD  `price_type` VARCHAR( 255 ) NULL;
	ALTER TABLE  {$this->getTable('picasso/group_option')} ADD  `price_config` TEXT NULL;
");

$installer->endSetup();