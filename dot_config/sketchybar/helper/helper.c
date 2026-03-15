#include "cpu.h"
#include "sketchybar.h"

struct cpu g_cpu;

void handler(env env) {
  char* name   = env_get_value_for_key(env, "NAME");
  char* sender = env_get_value_for_key(env, "SENDER");
  char* info   = env_get_value_for_key(env, "INFO");

  if ((strcmp(sender, "routine") == 0)
            || (strcmp(sender, "forced") == 0)) {
    cpu_update(&g_cpu);
    if (strlen(g_cpu.command) > 0) sketchybar(g_cpu.command);
  }
}

int main(int argc, char** argv) {
  cpu_init(&g_cpu);

  if (argc < 2) {
    printf("Usage: provider \"<bootstrap name>\"\n");
    exit(1);
  }

  event_server_begin(handler, argv[1]);
  return 0;
}
