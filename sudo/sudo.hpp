#include <string>

#define PATH "/bin/:/system/bin/:/system/xbin/:/system/sbin/:/sbin/"
#define ENV "HOME=/ SYSTEM_ROOT=/system FILESYSTEMS=/proc/filesystems MOUNTS=/proc/mounts"
#define VERSION "2.0"

#ifndef SUDO_H
#define SUDO_H
#endif

class logdata {
    
    public:
    uid_t uid;
    pid_t pid;
    pid_t parent_pid;
    gid_t gid;
    uid_t euid;
    std::string username;
    std::string content;
    
};

struct device_info {
    
    int secure_boot;
    bool rooted;
    std::string selinux;
    std::string su_path;
    
};

struct parser {
    
    int user;
    std::string user_id;
    int environment;
    
};

const std::string su_executeables_path[6] = { "/bin/su", "/sbin/su", "system/bin/su", "/system/xbin/su", "/system/sbin/su", "/magisk/.core/bin/su" };

void logger(std::string LOGFILE);

void usage(int status);

void signal_handler(int SIGTYPE);

void sudo(std::string storage);