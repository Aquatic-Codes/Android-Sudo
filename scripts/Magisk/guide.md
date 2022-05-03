# Magisk Module Guide

This guide would explain you some base functions of the module.

This module is recommended for all Android Versions using Magisk. The module would install sudo into system/bin/ allowing you to run it in apps using default PATH such as (Terminal Emulator For Android)[https://play.google.com/store/apps/details?id=jackpal.androidterm]. As of Magisk, the module file would be auto hidden when a app is in denylist or Magisk Hide. This method would prevent Bootloops.

## The system folder
This folder contains bin to paste bin files into bin.

#### Module.prop
Just a properties file.

# Stages
This module adds 2 extra stages to disable module on bootloops, note that not only this but all modules assosiated will be disabled. This can happen on dual reboot as well.

Stages:  
* Post FS Data - Confirm file and reboot
* Post FS Data - Create a record file
* Late Start - Remove file

## Post Fs Data

In this stage inside the module directory, a file check_reboot would be created. The way it works is mentioned below.

Firstly the script verifies if the file check_reboot is already available. If it's found to be available, all modules will be disabled and then a reboot would be performed. If the file wasn't available there, it would be created.

## Late Start Service

In this stage, the services checks and removes the file check_reboot. It is all it does and that's how we can confirm if the file is found to be available, then it means a reboot occured before system boot and the modules will be disabled.