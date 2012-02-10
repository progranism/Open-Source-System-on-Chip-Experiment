/*
 * This header file just defines some prototypes for the routines that we'll
 * use in the jtag_atlantic.dll.
 */

typedef struct JTAGATLANTIC JTAGATLANTIC;

JTAGATLANTIC * jtagatlantic_open(const char * chain, int device_index, int link_instance, const char * app_name);
int jtagatlantic_get_error(const char * * other_info);
void jtagatlantic_close(JTAGATLANTIC * link);
int jtagatlantic_write(JTAGATLANTIC * link, const char * data, unsigned int count);
int jtagatlantic_flush(JTAGATLANTIC * link);
int jtagatlantic_read(JTAGATLANTIC * link, char * buffer, unsigned int buffsize);
