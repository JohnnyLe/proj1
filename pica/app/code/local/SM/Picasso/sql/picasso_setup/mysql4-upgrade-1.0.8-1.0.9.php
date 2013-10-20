<?php
$installer = $this;

$installer->startSetup();

$installer->run("
    ALTER TABLE  {$this->getTable('picasso/group_option')} ADD  `available_step` varchar(255) NULL DEFAULT '';
");

$installer->endSetup();