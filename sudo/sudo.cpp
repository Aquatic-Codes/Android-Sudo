#include <iostream>
#include <string>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>

#include "sudo.hpp"

struct device_info device;
struct parser command_info;

#ifndef VERSION
#define VERSION "2.0"
#endif

using std::cout; using std::cin; using std::endl;

int main(int argc, char *argv[]) {
    
    logdata sudo_log;
    
    sudo_log.pid = getpid();
    sudo_log.parent_pid = getppid();
    sudo_log.uid = getuid();
    sudo_log.euid = geteuid();
    sudo_log.gid = getgid();
    sudo_log.username = getlogin();
    
    for (int i = 0; i < 6; i++) {
        
        if (access(su_executeables_path[i].c_str(), F_OK) == 0) {
            device.rooted = true;
            device.su_path = su_executeables_path[i];
        break;
        }
        
    }
    
    if (argc < 2) usage(1);
    
    if (device.rooted) {
        
        if (argc == 2)
            if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0) usage(0);
        
        std::string command;
        
        for (int i = 1; i < argc; i++) {
        
        if (strcmp(argv[i], "-u") == 0 || strcmp(argv[i], "--user") == 0) {
            
            if (argc < 3) usage(1);
            
            command_info.user = 1;
            command_info.user_id = argv[i+1];
            i++;
            continue;
            
        } else if (strcmp(argv[i], "-E") == 0 || strcmp(argv[i], "--preserve-environment") == 0) {
            
            command_info.environment = 1;
            continue;
            
        } else {
            
            if (command.length() <= 0)
            command.append(argv[i]);
            else
            command = command + " " + argv[i];
            
        }
        
    }
        
        sudo(command);
        
        } else {
        
        cout << "No superuser binary detected.\nIs device rooted?\n";
        exit(1);
        
    }
    
    return 0;
}

void usage(int status) {
    
    cout << "Seroid_Android - Sudo : 2.0\
    \nSudo - Run commands as another user.\
    \nusage: sudo [-u USER] -E [command]\
    \n\n  Options:\n\
    -u --user USER      Run commands as specified user.\n\
    -E --preserve-environment       Preserve Environmental Variables.\n";
    
    exit(status);
    
}

void sudo(std::string command) {
    
    std::string cmd = "exec";
    
    cmd = cmd + " " + device.su_path;
    
    if (command_info.environment) cmd = cmd + " " + "--preserve-environment";
    
    if (command_info.user) cmd = cmd + " " + command_info.user_id;
    
    cmd = cmd + " -c env -i PATH=" + PATH + " " + ENV + " " + command;
    
    system(cmd.c_str());
    
}

void signal_handler(int SIGTYPE) {
    
    if (SIGTYPE == SIGTERM) {
        cout << "Recived Terminate Request.\n";
        exit(0);
    } else if (SIGTYPE == SIGINT) {
        cout << "\n";
        exit(130);
    } else {
        signal(SIGTYPE, SIG_DFL);
    }
    
}
