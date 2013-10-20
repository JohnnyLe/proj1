<?php
$installer = $this;

$installer->startSetup();

$installer->run("
    ALTER TABLE  {$this->getTable('picasso/effect')} ADD  `default_brightness` INT(11) NULL DEFAULT '0';
    ALTER TABLE  {$this->getTable('picasso/effect')} ADD  `default_contrast` INT(11) NULL DEFAULT '0';
");

$installer->endSetup();