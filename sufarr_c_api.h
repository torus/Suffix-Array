// -*- mode: c++; c-basic-offset: 4; indent-tabs-mode: nil -*-
// Lua API
extern "C" {
    void* create_indexer (const char *path);
    void save_index (void *indexer, const char *path);
    void* load_index (const char *path, const char *src_path);
    int search_lower_bound (void *idx_p, const char *pat);
    int search_upper_bound (void *idx_p, const char *pat);
    const char * get_source_text (void *idx_p);
    int get_position (void *idx_p, int n);
}
