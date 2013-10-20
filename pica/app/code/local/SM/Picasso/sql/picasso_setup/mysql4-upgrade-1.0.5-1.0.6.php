<?php
$installer = $this;

$installer->startSetup();

$installer->run("
	ALTER TABLE  {$this->getTable('picasso/group_option')} ADD  `type` VARCHAR( 255 ) NULL
");

$installer->endSetup();