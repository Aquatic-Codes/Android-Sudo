#define SUDO_VER "1.0.0"

bool isRooted();

void setEnv();

void confirmArgs(int argc, char *argv[]);

void sudo(int environment, int user, char user_id[], char *command[]);