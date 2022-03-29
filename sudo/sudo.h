#include <string>

#define PATH "/bin/:/system/bin/:/system/xbin/:/system/sbin/:/sbin/"
#define ENV "HOME=/ SYSTEM_ROOT=/system FILESYSTEMS=/proc/filesystems MOUNTS=/proc/mounts"
#define VERSION "2.0"

struct device_info {
    
    int secure_boot;
    bool rooted;
    std::string selinux;
    std::string su_path;
    
};

struct user_info {
    
    pid_t pid;
    pid_t ppid;
    uid_t uid;
    uid_t euid;
    gid_t gid;
    gid_t egid;
    std::string username;
    
};

struct parser {
    
    int user;
    std::string user_id;
    int environment;
    
};

const std::string su_executeables_path[6] = { "/bin/su", "/sbin/su", "system/bin/su", "/system/xbin/su", "/system/sbin/su", "/magisk/.core/bin/su" };

void parse(int command_count, char *commands[], std::string storage);

void usage(int status);

void signal_handler(int SIGTYPE);

void sudo(std::string storage);