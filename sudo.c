/*

SuperUser-Do Binary for Android

Run command as root, Pending Features
To suggest features, comment in my post on reddit, u/AquaticGamerzYT
To raise issues, use the reddit or github

Version: 1.0.0

Documentation: Pending
Development: Pending/Under Development
*/

#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

#define SUDO_DEBUG_BUILD "0"
#define SUDO_LOGS_BUILD "0"
#define SUDO_LOGS_FILE "NULL"
#define SUDO_VER "1.0.0"

#define path "PATH=/bin:/system/bin/:/system/xbin/:/system/sbin/:/sbin/:/magisk/.core/bin/"

char env[10000] = "FILESYSTEMS_INFO=/proc/filesystems";

char su_executeable[25];

bool isRooted();

void usage() {
    printf("Android - sudo : 1.0.0\n\n\
\
sudo: Run command as root or other users.\n\
usage: sudo <options> command\n\
usage: sudo [-E] [-u user] command\n\n\
\
Options\n\
-E --preserve-environment       Preserve Env(s)\n\
-u --user USER       Run command as specified user instead of root\n\
");
exit(1);
}

void setEnv();


void sudo(int environment, int user, char user_id[], char *command[]);


void confirmArgs(int argc, char *argv[]);

int main(int argc, char *argv[]) {
    if (isRooted()) {
        
        if (argc == 1) usage();
        
        confirmArgs(argc, argv);
        
    } else {
        printf("SuperUser Not Found.\nIs this device Rooted?\n"); 
        exit(1);
    }
    
    return 0;
}

bool isRooted() {
    
    const char *executeables[] = {"/bin/su", "/system/bin/su", "/system/xbin/su", "/system/sbin/su", "/sbin/su", "/su/bin/su", "/magisk/.core/bin/su"};
    
    for (int i = 0; i < 7; i++) {//Start the loop
        if (access(executeables[i], F_OK) == 0) {
            sprintf(su_executeable, "%s", executeables[i]);
            return true;
        }
    }
    
    return false;
}

void setEnv() {
    
    char *envs[18] = { "EUID=0", "HOME=/" , "ANDDOID_DATA=/data/", "APP_DATA=/data/data/", "LOGNAME=root", "USER=root", "LANG=en_US.UTF-8", "TMPDIR=/data/local/tmp/", "SHELL=/system/bin/sh", "ANDROID_ROOT=/system/", "ANDROID_DEVICE_VENDOR=/vendor/", "ANDROID_TZDATA_ROOT=/apex/com.android.tzdata", "MOUNTS_FILE=/proc/mounts", "PARTITIONS_ROOT=/dev/block/by-name/", "ANDROID_ART_ROOT=/apex/com.android.art", "DEX2OATBOOTCLASSPATH=/apex/com.android.art/javalib/core-oj.jar:/apex/com.android.art/javalib/core-libart.jar:/apex/com.android.art/javalib/okhttp.jar:/apex/com.android.art/javalib/bouncycastle.jar:/apex/com.android.art/javalib/apache-xml.jar:/system/framework/framework.jar:/system/framework/framework-graphics.jar:/system/framework/ext.jar:/system/framework/telephony-common.jar:/system/framework/voip-common.jar:/system/framework/ims-common.jar:/apex/com.android.i18n/javalib/core-icu4j.jar:/system/framework/telephony-ext.jar", "BOOTCLASSPATH=/apex/com.android.art/javalib/core-oj.jar:/apex/com.android.art/javalib/core-libart.jar:/apex/com.android.art/javalib/okhttp.jar:/apex/com.android.art/javalib/bouncycastle.jar:/apex/com.android.art/javalib/apache-xml.jar:/system/framework/framework.jar:/system/framework/framework-graphics.jar:/system/framework/ext.jar:/system/framework/telephony-common.jar:/system/framework/voip-common.jar:/system/framework/ims-common.jar:/apex/com.android.i18n/javalib/core-icu4j.jar:/system/framework/telephony-ext.jar:/apex/com.android.appsearch/javalib/framework-appsearch.jar:/apex/com.android.conscrypt/javalib/conscrypt.jar:/apex/com.android.ipsec/javalib/android.net.ipsec.ike.jar:/apex/com.android.media/javalib/updatable-media.jar:/apex/com.android.mediaprovider/javalib/framework-mediaprovider.jar:/apex/com.android.os.statsd/javalib/framework-statsd.jar:/apex/com.android.permission/javalib/framework-permission.jar:/apex/com.android.permission/javalib/framework-permission-s.jar:/apex/com.android.scheduling/javalib/framework-scheduling.jar:/apex/com.android.sdkext/javalib/framework-sdkextensions.jar:/apex/com.android.tethering/javalib/framework-connectivity.jar:/apex/com.android.tethering/javalib/framework-tethering.jar:/apex/com.android.wifi/javalib/framework-wifi.jar" };
    
    // Setting environmental variables
    for (int i = 0; i < 17; i++) {
        if (i == 18) break;
        sprintf(env, "%s %s", env, envs[i]);
    }
    
}

void confirmArgs(int argc, char *argv[]) {
    int environment = 0;
    int user = 0;
    char command_pos = 0;
    
    // To ignore user and command and treat them as seperate arguments. 
    //To also know which user to switch if user is true.
    int user_pos = 0;
    char user_id[45];
    
    for (int i = 0; i < argc; i++) {
        if (strcmp(argv[i], "-E") == 0 || strcmp(argv[i], "--preserve-environment") == 0) {
        environment = 1;
        } else if (strcmp(argv[i], "-u") == 0 || strcmp(argv[i], "--user") == 0) {
            user = 1;
            user_pos = i+1;
            sprintf(user_id, "%s", argv[i+1]);
        } else {
            if (strstr(argv[i], "-")) {
                printf("Unknown Arguments are invalid: %s \n", argv[i]);
                exit(1);
            }
            if (i != user_pos) {
                command_pos = i;
                break;
            }
        }
        
    }
    
    int cmd_count = 0;
    char *command[152];
    
    do {
        
        if (command_pos == 0) usage();
        
        if (cmd_count == 150) break;
        
         command[cmd_count] = argv[command_pos];
         
        cmd_count++;
        command_pos++;
        
    } while (command_pos < argc);
    
    // Might be confusing but to know when to stop loop and execute commands as su.
    // Refer to sudo function's loop.
    command[cmd_count] = "DUDSendtheloopsofscans";
    
    setEnv();
    sudo(environment,user, user_id, command);
    
}

// Executed when everything is safe and proper data is recived. Will be documented soon.

void sudo(int environment, int user, char user_id[], char *command[]) {
    
      char cmd[10000];
      
      sprintf(cmd, "exec");
      sprintf(cmd, "%s", su_executeable);
      
      if (environment == 1) sprintf(cmd, "%s --preserve-environment", cmd);
      if (user == 1) sprintf(cmd, "%s %s", cmd, user_id);
      
      sprintf(cmd, "%s -c %s env -i %s", cmd, path, env);
      
    for (int i = 0; i < 152; i++) {
        if (strcmp(command[i], "DUDSendtheloopsofscans") == 0) break;
        
        sprintf(cmd, "%s %s", cmd, command[i]);
    }
    
    // Execute command as root.
    system(cmd);
    
}