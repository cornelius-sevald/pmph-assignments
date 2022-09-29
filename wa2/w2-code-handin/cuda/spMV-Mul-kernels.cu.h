#ifndef SP_MV_MUL_KERS
#define SP_MV_MUL_KERS

__global__ void
replicate0(int tot_size, char* flags_d) {
    uint32_t gid = blockIdx.x * blockDim.x + threadIdx.x;
    if(gid < tot_size) {
        flags_d[gid] = 0;
    }
}

__global__ void
mkFlags(int mat_rows, int* mat_shp_sc_d, char* flags_d) {
    uint32_t gid = blockIdx.x * blockDim.x + threadIdx.x;
    if(gid == 0) {
        flags_d[0] = 1;
    } else if(gid < mat_rows) {
        if (mat_shp_sc_d[gid-1] != mat_shp_sc_d[gid]) {
            flags_d[mat_shp_sc_d[gid-1]] = 1;
        }
    }
}

__global__ void 
mult_pairs(int* mat_inds, float* mat_vals, float* vct, int tot_size, float* tmp_pairs) {
    uint32_t gid = blockIdx.x * blockDim.x + threadIdx.x;
    if (gid < tot_size) {
        unsigned int i = mat_inds[gid];
        float v = mat_vals[gid];
        tmp_pairs[gid] = v * vct[i];
    }
}

__global__ void
select_last_in_sgm(int mat_rows, int* mat_shp_sc_d, float* tmp_scan, float* res_vct_d) {
    uint32_t gid = blockIdx.x * blockDim.x + threadIdx.x;
    if(gid == 0) {
        res_vct_d[0] = tmp_scan[mat_shp_sc_d[gid]-1];
    } else if(gid < mat_rows) {
        if (mat_shp_sc_d[gid-1] != mat_shp_sc_d[gid]) {
            res_vct_d[gid] = tmp_scan[mat_shp_sc_d[gid]-1];
        } else {
            res_vct_d[gid] = 0.0;
        }
    }
}

#endif
