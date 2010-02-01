// Lua API
extern "C" {
    void* create_indexer (const char *path);
    void save_index (void *indexer, const char *path);
    void* load_index (const char *path, const char *src_path);
    int search_lower_bound (void *idx_p, const char *pat);
    int search_upper_bound (void *idx_p, const char *pat);
}
