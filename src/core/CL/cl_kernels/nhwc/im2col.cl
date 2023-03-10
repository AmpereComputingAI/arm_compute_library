/*
 * Copyright (c) 2018-2021 Arm Limited.
 *
 * SPDX-License-Identifier: MIT
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
#include "helpers.h"

#define VECTOR_N VEC_DATA_TYPE(DATA_TYPE, VECTOR_SIZE)
#define COND_N SIGNED_INT_VEC_DATA_TYPE(DATA_TYPE, VECTOR_SIZE)

#if defined(IM2COL_3X3) || defined(IM2COL_9X9)
/** Store a 1x9 row or a 3x3 block in a boundary-aware manner to avoid paddings in the channel dimension
 *  @name IM2COL1X9_NHWC_STORE
 *
 *  @note To use this macro for a 3x3 block, @p ROW has to be 0
 *
 * @param[in] VECTOR_SIZE          The non-boundary vector width of @p DATA. Supported: 1(scalar), 2, 3, 4, 8, 16
 * @param[in] BOUNDARY_VECTOR_SIZE The boundary vector width of @p DATA. Supported: 1-16, but has to be <= @p size
 * @param[in] DATA_TYPE            Data type of @p DATA
 * @param[in] SRC_DEPTH            Input channel size / depth
 * @param[in] DATA                 Value variable base name
 * @param[in] ROW                  The row number to store. Supported: 0-8
 * @param[in] OUTPUT_PTR           Output pointer
 * @{
 */
#if defined(VECTOR_SIZE) && defined(BOUNDARY_VECTOR_SIZE) && BOUNDARY_VECTOR_SIZE < VECTOR_SIZE
#define IM2COL1X9_NHWC_STORE(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE, DATA_TYPE, SRC_DEPTH, DATA, ROW, OUTPUT_PTR)         \
    const bool at_channel_boundary = get_global_id(0) == 0;                                                          \
    if(at_channel_boundary)                                                                                          \
    {                                                                                                                \
        IM2COL1X9_NHWC_STORE_PARTIAL(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE, DATA_TYPE, SRC_DEPTH, DATA, ROW, OUTPUT_PTR) \
    }                                                                                                                \
    else                                                                                                             \
    {                                                                                                                \
        IM2COL1X9_NHWC_STORE_NONPARTIAL(VECTOR_SIZE, DATA_TYPE, SRC_DEPTH, DATA, ROW, OUTPUT_PTR)                    \
    }
#else // defined(VECTOR_SIZE) && defined(BOUNDARY_VECTOR_SIZE) && BOUNDARY_VECTOR_SIZE < VECTOR_SIZE
#define IM2COL1X9_NHWC_STORE(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE, DATA_TYPE, SRC_DEPTH, DATA, ROW, OUTPUT_PTR) \
    IM2COL1X9_NHWC_STORE_NONPARTIAL(VECTOR_SIZE, DATA_TYPE, SRC_DEPTH, DATA, ROW, OUTPUT_PTR)
#endif // defined(VECTOR_SIZE) && defined(BOUNDARY_VECTOR_SIZE) && BOUNDARY_VECTOR_SIZE < VECTOR_SIZE

#define IM2COL1X9_NHWC_STORE_NONPARTIAL(VECTOR_SIZE, DATA_TYPE, SRC_DEPTH, DATA, ROW, OUTPUT_PTR) \
    VSTORE(VECTOR_SIZE)                                                                           \
    (DATA##0, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (0 + ROW * 9) * SRC_DEPTH);                 \
    VSTORE(VECTOR_SIZE)                                                                           \
    (DATA##1, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (1 + ROW * 9) * SRC_DEPTH);                 \
    VSTORE(VECTOR_SIZE)                                                                           \
    (DATA##2, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (2 + ROW * 9) * SRC_DEPTH);                 \
    VSTORE(VECTOR_SIZE)                                                                           \
    (DATA##3, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (3 + ROW * 9) * SRC_DEPTH);                 \
    VSTORE(VECTOR_SIZE)                                                                           \
    (DATA##4, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (4 + ROW * 9) * SRC_DEPTH);                 \
    VSTORE(VECTOR_SIZE)                                                                           \
    (DATA##5, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (5 + ROW * 9) * SRC_DEPTH);                 \
    VSTORE(VECTOR_SIZE)                                                                           \
    (DATA##6, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (6 + ROW * 9) * SRC_DEPTH);                 \
    VSTORE(VECTOR_SIZE)                                                                           \
    (DATA##7, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (7 + ROW * 9) * SRC_DEPTH);                 \
    VSTORE(VECTOR_SIZE)                                                                           \
    (DATA##8, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (8 + ROW * 9) * SRC_DEPTH);

#define IM2COL1X9_NHWC_STORE_PARTIAL(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE, DATA_TYPE, SRC_DEPTH, DATA, ROW, OUTPUT_PTR) \
    VSTORE_PARTIAL(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE)                                                                \
    (DATA##0, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (0 + ROW * 9) * SRC_DEPTH);                                    \
    VSTORE_PARTIAL(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE)                                                                \
    (DATA##1, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (1 + ROW * 9) * SRC_DEPTH);                                    \
    VSTORE_PARTIAL(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE)                                                                \
    (DATA##2, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (2 + ROW * 9) * SRC_DEPTH);                                    \
    VSTORE_PARTIAL(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE)                                                                \
    (DATA##3, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (3 + ROW * 9) * SRC_DEPTH);                                    \
    VSTORE_PARTIAL(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE)                                                                \
    (DATA##4, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (4 + ROW * 9) * SRC_DEPTH);                                    \
    VSTORE_PARTIAL(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE)                                                                \
    (DATA##5, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (5 + ROW * 9) * SRC_DEPTH);                                    \
    VSTORE_PARTIAL(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE)                                                                \
    (DATA##6, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (6 + ROW * 9) * SRC_DEPTH);                                    \
    VSTORE_PARTIAL(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE)                                                                \
    (DATA##7, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (7 + ROW * 9) * SRC_DEPTH);                                    \
    VSTORE_PARTIAL(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE)                                                                \
    (DATA##8, 0, (__global DATA_TYPE *)(OUTPUT_PTR) + (8 + ROW * 9) * SRC_DEPTH);
/** @}*/
#endif // defined(IM2COL_3X3) || defined(IM2COL_9X9)

#if defined(IM2COL_3X3)
/** This kernel performs im2col when the kernel size is 3x3 and the data layout is NHWC
 *
 * @note This kernel computes VECTOR_SIZE elements
 * @note This kernel stores VECTOR_SIZE or BOUNDARY_VECTOR_SIZE (if at boundary) elements
 * @note The vector size must be passed at compile time using -DVECTOR_SIZE: e.g. -DVECTOR_SIZE=2
 * @note The boundary vector size must be passed at compile time using -DBOUNDARY_VECTOR_SIZE: e.g. -DBOUNDARY_VECTOR_SIZE=1
 * @note The data type must be passed at compile time using -DDATA_TYPE: e.g. -DDATA_TYPE=float
 * @note The width of output tensor after matrix multiplication must be passed at compile time using -DCONVOLVED_WIDTH: e.g. -DCONVOLVED_WIDTH=34
 * @note The kernel depth must be passed at compile time using -DSRC_DEPTH: e.g. -DSRC_DEPTH=3
 * @note The stride along the Y direction must be passed at compile time using -DSTRIDE_Y: e.g. -DSTRIDE_Y=1
 * @note In case biases will be added to the convolution -DHAS_BIAS has to be passed to append the final matrix with 1 in each row.
 *
 * @param[in]  src_ptr                           Pointer to the source tensor. Supported data types: QASYMM8_SIGNED/QASYMM8/F16/F32
 * @param[in]  src_stride_x                      Stride of the source tensor in X dimension (in bytes)
 * @param[in]  src_step_x                        src_stride_x * number of elements along X processed per workitem(in bytes)
 * @param[in]  src_stride_y                      Stride of the source tensor in Y dimension (in bytes)
 * @param[in]  src_step_y                        src_stride_y * number of elements along Y processed per workitem(in bytes)
 * @param[in]  src_stride_z                      Stride of the source tensor in Z dimension (in bytes)
 * @param[in]  src_step_z                        src_stride_z * number of elements along Z processed per workitem(in bytes)
 * @param[in]  src_offset_first_element_in_bytes The offset of the first element in the source tensor
 * @param[out] dst_ptr                           Pointer to the destination tensor. Supported data types: same as @p src_ptr
 * @param[in]  dst_stride_x                      Stride of the destination tensor in X dimension (in bytes)
 * @param[in]  dst_step_x                        dst_stride_x * number of elements along X processed per workitem(in bytes)
 * @param[in]  dst_stride_y                      Stride of the destination tensor in Y dimension (in bytes)
 * @param[in]  dst_step_y                        dst_stride_y * number of elements along Y processed per workitem(in bytes)
 * @param[in]  dst_offset_first_element_in_bytes The offset of the first element in the destination tensor
 * @param[in]  src_stride_w                      Stride of the source tensor in W dimension (in bytes).
 * @param[in]  dst_stride_w                      Stride of the destination tensor in W dimension (in bytes).
 */
__kernel void im2col3x3_nhwc(
    TENSOR3D_DECLARATION(src),
    IMAGE_DECLARATION(dst),
    uint src_stride_w,
    uint dst_stride_w)
{
    // input feature map, boundary-corrected (shift all non-boundary vectors by shift_amount) to avoid padding
    const int shift_amount = (int)VECTOR_SIZE - (int)BOUNDARY_VECTOR_SIZE;
    const int ch           = max((int)(get_global_id(0) * VECTOR_SIZE) - shift_amount, 0);
    const int yo           = get_global_id(1);
    const int batch        = get_global_id(2); // batch size

    // Calculate input indices
    const int xi = (get_global_id(1) % CONVOLVED_WIDTH) * STRIDE_X;
    const int yi = (get_global_id(1) / (int)CONVOLVED_WIDTH) * STRIDE_Y;

    // Get input and output address
    __global uchar *input_ptr  = src_ptr + src_offset_first_element_in_bytes + ch * sizeof(DATA_TYPE) + batch * (int)src_stride_w;
    __global uchar *output_ptr = dst_ptr + dst_offset_first_element_in_bytes + ch * sizeof(DATA_TYPE) + yo * (int)dst_stride_y + batch * (int)dst_stride_w;

    int  yi_coord = 0;
    int3 offset   = 0;

    // Clamp xi
    int3 xi_offset = ((int3)xi + (int3)(0, 1, 2) * DILATION_X - (int3)PAD_LEFT);
#if PAD_LEFT != 0 || PAD_RIGHT != 0
#define CLAMP(x, min_val, max_val) min(max(x, min_val), max_val)
    xi_offset = CLAMP(xi_offset, (int3)0, (int3)(SRC_WIDTH - 1));
#endif // PAD_LEFT != 0 || PAD_RIGHT != 0
    // Multiply by src_stride_y as the width (X) dimension here is the second (y) dimension in src NHWC tensor
    xi_offset *= (int3)src_stride_y;

    // Out-of-bound condition for X
    int3 x_cond = (((int3)xi + (int3)(0, 1, 2) * DILATION_X - (int3)PAD_LEFT) < (int3)0) || (((int3)xi + (int3)(0, 1, 2) * DILATION_X - (int3)PAD_LEFT) >= (int3)SRC_WIDTH);

    // yi == 0
    // Clamp yi
    // yi_coord is casted to unsigned int in order to use just a min() operation
    // A "-1" 32 bit signed variable converted to unsigned gives 4294967295
    // This is a trick so that the values loaded in the padding areas are always from the last row (SRC_HEIGHT - 1),
    // because of the negative yi_coord wrap-around, but it gets overwritten by PAD_VALUE immediately as the wrap-around
    // also causes y_cond (y padding condition) to be satisfied
    yi_coord = yi - (int)PAD_TOP;

    // Clamp only if PAD_TOP or PAD_BOTTOM is not equal to 0
#if PAD_TOP != 0 || PAD_BOTTOM != 0
    yi_coord = min((uint)yi_coord, (uint)(SRC_HEIGHT - 1));
#endif // PAD_TOP != 0 || PAD_BOTTOM != 0

    // Compute offset
    offset = xi_offset + (yi_coord * (int)src_stride_z);

    // Load input values
    VECTOR_N values0 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset.s0));
    VECTOR_N values1 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset.s1));
    VECTOR_N values2 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset.s2));

#if PAD_TOP != 0 || PAD_LEFT != 0 || PAD_BOTTOM != 0 || PAD_RIGHT != 0
    // Replace invalid values with PAD_VALUE
    int y_cond = (int)((uint)(yi - (int)PAD_TOP) >= (uint)(SRC_HEIGHT));
    values0    = select(values0, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond.s0)));
    values1    = select(values1, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond.s1)));
    values2    = select(values2, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond.s2)));
#endif // PAD_TOP != 0 || PAD_LEFT != 0 || PAD_BOTTOM != 0 || PAD_RIGHT != 0

    // yi == 1
    // Clamp yi_coord (it can be negative if PAD_TOP > 1)
    yi_coord = yi - (int)PAD_TOP + 1 * DILATION_Y;

    // Clamp only if PAD_TOP or PAD_BOTTOM is not equal to 0
#if PAD_TOP != 0 || PAD_BOTTOM != 0
    yi_coord = min((uint)yi_coord, (uint)(SRC_HEIGHT - 1));
#endif // PAD_TOP != 0 || PAD_BOTTOM != 0

    // Compute offset
    offset = xi_offset + (yi_coord * (int)src_stride_z);

    // Load input values
    VECTOR_N values3 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset.s0));
    VECTOR_N values4 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset.s1));
    VECTOR_N values5 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset.s2));

#if PAD_TOP != 0 || PAD_LEFT != 0 || PAD_BOTTOM != 0 || PAD_RIGHT != 0
    // Replace invalid values with zeros
    y_cond  = (int)((uint)(yi - (int)PAD_TOP + 1 * DILATION_Y) >= (uint)(SRC_HEIGHT));
    values3 = select(values3, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond.s0)));
    values4 = select(values4, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond.s1)));
    values5 = select(values5, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond.s2)));
#endif // PAD_TOP != 0 || PAD_LEFT != 0 || PAD_BOTTOM != 0 || PAD_RIGHT != 0

    // yi == 2
    // Clamp yi_coord
    yi_coord = yi - (int)PAD_TOP + 2 * DILATION_Y;

    // Clamp only if PAD_TOP or PAD_BOTTOM is not equal to 0
#if PAD_TOP != 0 || PAD_BOTTOM != 0
    yi_coord = min((uint)yi_coord, (uint)(SRC_HEIGHT - 1));
#endif // PAD_TOP != 0 || PAD_BOTTOM != 0

    // Compute offset
    offset = xi_offset + (yi_coord * (int)src_stride_z);

    // Load input values
    VECTOR_N values6 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset.s0));
    VECTOR_N values7 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset.s1));
    VECTOR_N values8 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset.s2));

#if PAD_TOP != 0 || PAD_LEFT != 0 || PAD_BOTTOM != 0 || PAD_RIGHT != 0
    // Replace invalid values with PAD_VALUE
    y_cond  = (int)((uint)(yi - (int)PAD_TOP + 2 * DILATION_Y) >= (uint)(SRC_HEIGHT));
    values6 = select(values6, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond.s0)));
    values7 = select(values7, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond.s1)));
    values8 = select(values8, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond.s2)));
#endif // PAD_TOP != 0 || PAD_LEFT != 0 || PAD_BOTTOM != 0 || PAD_RIGHT != 0

    // Store in a boundary-aware way to avoid padding
    IM2COL1X9_NHWC_STORE(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE, DATA_TYPE, SRC_DEPTH, values, 0, output_ptr)

#ifdef HAS_BIAS
    // We can use VECTOR_SIZE instead of BOUNDARY_VECTOR_SIZE even if it's at the boundary. This is because the bias is
    // added at the end of the channel, while the boundary vec is at the beginning of the channel.
    // The only case where the boundary vec is at the end of the channel is when there's only a single boundary vec in
    // the whole channel dimension, but in that case VECTOR_SIZE is also equal to BOUNDARY_VECTOR_SIZE
    // See the value of num_elems_processed_per_iteration in configure_opencl_kernel method in CLIm2ColKernel.cpp
    if((ch + VECTOR_SIZE) >= SRC_DEPTH)
    {
        *((__global DATA_TYPE *)(output_ptr) - ch + SRC_DEPTH * 9) = 1.0f;
    }
#endif // HAS_BIAS
}
#endif // defined(IM2COL_3X3)

#if defined(IM2COL_9X9)
#if PAD_TOP != 0 || PAD_LEFT != 0 || PAD_BOTTOM != 0 || PAD_RIGHT != 0
#define IM2COL1x9(i)                                                                                         \
    ({                                                                                                       \
        yi_coord = yi - (int)PAD_TOP + i * DILATION_Y;                                                       \
        yi_coord = min((uint)yi_coord, (uint)(SRC_HEIGHT - 1));                                              \
        \
        offset0 = xi_offset0 + (yi_coord * (int)src_stride_z);                                               \
        offset1 = xi_offset1 + (yi_coord * (int)src_stride_z);                                               \
        \
        VECTOR_N values0 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s0));            \
        VECTOR_N values1 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s1));            \
        VECTOR_N values2 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s2));            \
        VECTOR_N values3 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s3));            \
        VECTOR_N values4 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s4));            \
        VECTOR_N values5 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s5));            \
        VECTOR_N values6 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s6));            \
        VECTOR_N values7 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s7));            \
        VECTOR_N values8 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset1));               \
        \
        int y_cond = (int)((uint)(yi - (int)PAD_TOP + i * DILATION_Y) >= (uint)(SRC_HEIGHT));                \
        values0    = select(values0, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond0.s0))); \
        values1    = select(values1, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond0.s1))); \
        values2    = select(values2, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond0.s2))); \
        values3    = select(values3, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond0.s3))); \
        values4    = select(values4, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond0.s4))); \
        values5    = select(values5, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond0.s5))); \
        values6    = select(values6, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond0.s6))); \
        values7    = select(values7, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond0.s7))); \
        values8    = select(values8, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)y_cond || (COND_N)(x_cond1)));    \
        \
        IM2COL1X9_NHWC_STORE(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE, DATA_TYPE, SRC_DEPTH, values, i, output_ptr) \
    })
#else // PAD_TOP != 0 || PAD_LEFT != 0 || PAD_BOTTOM != 0 || PAD_RIGHT != 0
#define IM2COL1x9(i)                                                                                         \
    ({                                                                                                       \
        yi_coord = yi - (int)PAD_TOP + i * DILATION_Y;                                                       \
        yi_coord = min((uint)yi_coord, (uint)(SRC_HEIGHT - 1));                                              \
        \
        offset0 = xi_offset0 + (yi_coord * (int)src_stride_z);                                               \
        offset1 = xi_offset1 + (yi_coord * (int)src_stride_z);                                               \
        \
        VECTOR_N values0 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s0));            \
        VECTOR_N values1 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s1));            \
        VECTOR_N values2 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s2));            \
        VECTOR_N values3 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s3));            \
        VECTOR_N values4 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s4));            \
        VECTOR_N values5 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s5));            \
        VECTOR_N values6 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s6));            \
        VECTOR_N values7 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset0.s7));            \
        VECTOR_N values8 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset1));               \
        \
        IM2COL1X9_NHWC_STORE(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE, DATA_TYPE, SRC_DEPTH, values, i, output_ptr) \
    })
#endif // PAD_TOP != 0 || PAD_LEFT != 0 || PAD_BOTTOM != 0 || PAD_RIGHT != 0

/** This kernel performs im2col when the kernel size is 9x9 and the data layout is NHWC
 *
 * @note This kernel computes VECTOR_SIZE elements
 * @note This kernel stores VECTOR_SIZE or BOUNDARY_VECTOR_SIZE (if at boundary) elements
 * @note The vector size must be passed at compile time using -DVECTOR_SIZE: e.g. -DVECTOR_SIZE=2
 * @note The boundary vector size must be passed at compile time using -DBOUNDARY_VECTOR_SIZE: e.g. -DBOUNDARY_VECTOR_SIZE=1
 * @note The data type must be passed at compile time using -DDATA_TYPE: e.g. -DDATA_TYPE=float
 * @note The width of output tensor after matrix multiplication must be passed at compile time using -DCONVOLVED_WIDTH: e.g. -DCONVOLVED_WIDTH=34
 * @note The kernel depth must be passed at compile time using -DSRC_DEPTH: e.g. -DSRC_DEPTH=3
 * @note The stride along the Y direction must be passed at compile time using -DSTRIDE_Y: e.g. -DSTRIDE_Y=1
 * @note In case biases will be added to the convolution -DHAS_BIAS has to be passed to append the final matrix with 1 in each row.
 *
 * @param[in]  src_ptr                           Pointer to the source tensor. Supported data types: QASYMM8_SIGNED/QASYMM8/F16/F32
 * @param[in]  src_stride_x                      Stride of the source tensor in X dimension (in bytes)
 * @param[in]  src_step_x                        src_stride_x * number of elements along X processed per workitem(in bytes)
 * @param[in]  src_stride_y                      Stride of the source tensor in Y dimension (in bytes)
 * @param[in]  src_step_y                        src_stride_y * number of elements along Y processed per workitem(in bytes)
 * @param[in]  src_stride_z                      Stride of the source tensor in Z dimension (in bytes)
 * @param[in]  src_step_z                        src_stride_z * number of elements along Z processed per workitem(in bytes)
 * @param[in]  src_offset_first_element_in_bytes The offset of the first element in the source tensor
 * @param[out] dst_ptr                           Pointer to the destination tensor. Supported data types: same as @p src_ptr
 * @param[in]  dst_stride_x                      Stride of the destination tensor in X dimension (in bytes)
 * @param[in]  dst_step_x                        dst_stride_x * number of elements along X processed per workitem(in bytes)
 * @param[in]  dst_stride_y                      Stride of the destination tensor in Y dimension (in bytes)
 * @param[in]  dst_step_y                        dst_stride_y * number of elements along Y processed per workitem(in bytes)
 * @param[in]  dst_offset_first_element_in_bytes The offset of the first element in the destination tensor
 * @param[in]  src_stride_w                      Stride of the source tensor in W dimension (in bytes).
 * @param[in]  dst_stride_w                      Stride of the destination tensor in W dimension (in bytes).
 */
__kernel void im2col9x9_nhwc(
    TENSOR3D_DECLARATION(src),
    IMAGE_DECLARATION(dst),
    uint src_stride_w,
    uint dst_stride_w)
{
    // input feature map, boundary-corrected (shift all non-boundary vectors by shift_amount) to avoid padding
    const int shift_amount = (int)VECTOR_SIZE - (int)BOUNDARY_VECTOR_SIZE;
    const int ch           = max((int)(get_global_id(0) * VECTOR_SIZE) - shift_amount, 0);
    const int yo           = get_global_id(1);
    const int batch        = get_global_id(2); // batch size

    // Calculate input indices
    const int xi = (get_global_id(1) % CONVOLVED_WIDTH) * STRIDE_X;
    const int yi = (get_global_id(1) / (int)CONVOLVED_WIDTH) * STRIDE_Y;

    // Get input and output address
    __global uchar *input_ptr  = src_ptr + src_offset_first_element_in_bytes + ch * sizeof(DATA_TYPE) + batch * (int)src_stride_w;
    __global uchar *output_ptr = dst_ptr + dst_offset_first_element_in_bytes + ch * sizeof(DATA_TYPE) + yo * (int)dst_stride_y + batch * (int)dst_stride_w;

    int  yi_coord = 0;
    int8 offset0  = 0;
    int  offset1  = 0;

    // Clamp xi
    int8 xi_offset0 = ((int8)xi + (int8)(0, 1, 2, 3, 4, 5, 6, 7) * DILATION_X - (int8)PAD_LEFT);
    int  xi_offset1 = ((int)xi + (int)(8) * DILATION_X - (int)PAD_LEFT);

#if PAD_LEFT != 0 || PAD_RIGHT != 0
#define CLAMP(x, min_val, max_val) min(max(x, min_val), max_val)
    xi_offset0 = CLAMP(xi_offset0, (int8)0, (int8)(SRC_WIDTH - 1));
    xi_offset1 = CLAMP(xi_offset1, (int)0, (int)(SRC_WIDTH - 1));
#endif // PAD_LEFT != 0 || PAD_RIGHT != 0
    xi_offset0 *= (int8)src_stride_y;
    xi_offset1 *= (int)src_stride_y;

    // Out-of-bound condition for X
    int8 x_cond0 = (((int8)xi + (int8)(0, 1, 2, 3, 4, 5, 6, 7) * DILATION_X - (int8)PAD_LEFT) < (int8)0) || (((int8)xi + (int8)(0, 1, 2, 3, 4, 5, 6, 7) * DILATION_X - (int8)PAD_LEFT) >= (int8)SRC_WIDTH);
    int  x_cond1 = (((int)xi + (int)(8) * DILATION_X - (int)PAD_LEFT) < (int)0) || (((int)xi + (int)(8) * DILATION_X - (int)PAD_LEFT) >= (int)SRC_WIDTH);

    IM2COL1x9(0);
    IM2COL1x9(1);
    IM2COL1x9(2);
    IM2COL1x9(3);
    IM2COL1x9(4);
    IM2COL1x9(5);
    IM2COL1x9(6);
    IM2COL1x9(7);
    IM2COL1x9(8);

#ifdef HAS_BIAS
    // We can use VECTOR_SIZE instead of BOUNDARY_VECTOR_SIZE even if it's at the boundary. This is because the bias is
    // added at the end of the channel, while the boundary vec is at the beginning of the channel.
    // The only case where the boundary vec is at the end of the channel is when there's only a single boundary vec in
    // the whole channel dimension, but in that case VECTOR_SIZE is also equal to BOUNDARY_VECTOR_SIZE
    // See the value of num_elems_processed_per_iteration in configure_opencl_kernel method in CLIm2ColKernel.cpp
    if((ch + VECTOR_SIZE) >= SRC_DEPTH)
    {
        *((__global DATA_TYPE *)(output_ptr) - ch + SRC_DEPTH * 81) = 1.0f;
    }
#endif // HAS_BIAS
}
#endif // defined(IM2COL_9X9)

#if defined(IM2COL_GENERIC)
/** This opencl kernel performs a generic im2col implementation when the data layout is NHWC
 *
 * @note This kernel computes VECTOR_SIZE elements
 * @note This kernel stores VECTOR_SIZE or BOUNDARY_VECTOR_SIZE (if at boundary) elements
 * @note The vector size must be passed at compile time using -DVECTOR_SIZE: e.g. -DVECTOR_SIZE=2
 * @note The boundary vector size must be passed at compile time using -DBOUNDARY_VECTOR_SIZE: e.g. -DBOUNDARY_VECTOR_SIZE=1
 * @note The data type must be passed at compile time using -DDATA_TYPE: e.g. -DDATA_TYPE=float
 * @note The width and height of the input tensor must be passed at compile time using -DSRC_WIDTH and -DSRC_HEIGHT: e.g. -DSRC_WIDTH=128 and -DSRC_HEIGHT=128
 * @note The width of output tensor after matrix multiplication must be passed at compile time using -DCONVOLVED_WIDTH: e.g. -DCONVOLVED_WIDTH=34
 * @note The kernel width, height and depth must be passed at compile time using -DKERNEL_WIDTH, -DKERNEL_HEIGHT and -DSRC_DEPTH: e.g. -DKERNEL_WIDTH=3, -DKERNEL_HEIGHT=3 and -DSRC_DEPTH=64
 * @note The pad_left, pad_right, pad_top and pad_bottom must be passed at compile time using -DPAD_LEFT, -DPAD_RIGHT, -DPAD_TOP and -DPAD_BOTTOM: e.g. -DPAD_LEFT=1, -DPAD_RIGHT=2, -DPAD_TOP=3 and -DPAD_BOTTOM=2
 * @note The zero value to store in case we load values out-of-bounds must be passed at compile time using -DPAD_VALUE: e.g. -DPAD_VALUE=0.0
 * @note The stride along the X and Y directions must be passed at compile time using -DSTRIDE_X and -DSTRIDE_Y: e.g. -DSTRIDE_X=1 and -DSTRIDE_Y=1
 * @note The dilation_x and dilation_y must be passed at compile time using -DDILATION_X and -DDILATION_Y: e.g. -DDILATION_X=1, -DDILATION_Y=1
 * @note In case biases will be added to the convolution -DHAS_BIAS has to be passed to append the final matrix with 1 in each row.
 *
 * @param[in]  src_ptr                           Pointer to the source tensor. Supported data types: QASYMM8_SIGNED/QASYMM8/F16/F32
 * @param[in]  src_stride_x                      Stride of the source tensor in X dimension (in bytes)
 * @param[in]  src_step_x                        src_stride_x * number of elements along X processed per workitem(in bytes)
 * @param[in]  src_stride_y                      Stride of the source tensor in Y dimension (in bytes)
 * @param[in]  src_step_y                        src_stride_y * number of elements along Y processed per workitem(in bytes)
 * @param[in]  src_stride_z                      Stride of the source tensor in Z dimension (in bytes)
 * @param[in]  src_step_z                        src_stride_z * number of elements along Z processed per workitem(in bytes)
 * @param[in]  src_offset_first_element_in_bytes The offset of the first element in the source tensor
 * @param[out] dst_ptr                           Pointer to the destination tensor. Supported data types: same as @p src_ptr
 * @param[in]  dst_stride_x                      Stride of the destination tensor in X dimension (in bytes)
 * @param[in]  dst_step_x                        dst_stride_x * number of elements along X processed per workitem(in bytes)
 * @param[in]  dst_stride_y                      Stride of the destination tensor in Y dimension (in bytes)
 * @param[in]  dst_step_y                        dst_stride_y * number of elements along Y processed per workitem(in bytes)
 * @param[in]  dst_offset_first_element_in_bytes The offset of the first element in the destination tensor
 * @param[in]  src_stride_w                      Stride of the source tensor in W dimension (in bytes).
 * @param[in]  dst_stride_w                      Stride of the destination tensor in W dimension (in bytes).
 */
__kernel void im2col_generic_nhwc(
    TENSOR3D_DECLARATION(src),
    IMAGE_DECLARATION(dst),
    uint src_stride_w,
    uint dst_stride_w)
{
    // input feature map, boundary-corrected (shift all non-boundary vectors by shift_amount) to avoid padding
    const int shift_amount = (int)VECTOR_SIZE - (int)BOUNDARY_VECTOR_SIZE;
    const int ch           = max((int)(get_global_id(0) * VECTOR_SIZE) - shift_amount, 0);
    const int yo           = get_global_id(1);
    const int batch        = get_global_id(2); // batch size

    // Calculate input indices
    const int xi = (yo % CONVOLVED_WIDTH) * STRIDE_X;
    const int yi = (yo / (int)CONVOLVED_WIDTH) * STRIDE_Y;

    // Get input and output address
    const int stride_x         = ch * sizeof(DATA_TYPE);
    __global uchar *input_ptr  = src_ptr + src_offset_first_element_in_bytes + stride_x + batch * (int)src_stride_w;
    __global uchar *output_ptr = dst_ptr + dst_offset_first_element_in_bytes + stride_x + yo * (int)dst_stride_y + batch * (int)dst_stride_w;

    int i = 0;
    for(int yk = 0; yk < KERNEL_HEIGHT; ++yk)
    {
        // Clamp yi_coord
        int yi_coord = yi + yk * DILATION_Y - (int)PAD_TOP;
        yi_coord     = clamp(yi_coord, (int)0, (int)(SRC_HEIGHT - 1));

        // Out-of-bound condition for Y
        int y_border_condition = ((yi + yk * DILATION_Y - (int)PAD_TOP) < (int)0) || ((yi + yk * DILATION_Y - (int)PAD_TOP) >= (int)SRC_HEIGHT);

        for(int xk = 0; xk < KERNEL_WIDTH; ++xk)
        {
            // Clamp xi_coord
            int xi_coord = (xi + xk * DILATION_X - (int)PAD_LEFT);
            xi_coord     = clamp(xi_coord, (int)0, (int)(SRC_WIDTH - 1));

            // Out-of-bound condition for X
            int x_border_condition = ((xi + xk * DILATION_X - (int)PAD_LEFT) < (int)0) || ((xi + xk * DILATION_X - (int)PAD_LEFT) >= (int)SRC_WIDTH);

            int offset = xi_coord * (int)src_stride_y + (yi_coord * (int)src_stride_z);

            VECTOR_N values0 = VLOAD(VECTOR_SIZE)(0, (__global DATA_TYPE *)(input_ptr + offset));

#if PAD_LEFT != 0 || PAD_TOP != 0 || PAD_RIGHT != 0 || PAD_BOTTOM != 0
            // Replace with PAD_VALUE if the value is out-of-bound
            values0 = select(values0, (VECTOR_N)PAD_VALUE, (COND_N)((COND_N)x_border_condition || (COND_N)(y_border_condition)));
#endif // PAD_LEFT != 0 || PAD_TOP != 0 || PAD_RIGHT != 0 || PAD_BOTTOM != 0

            // Store in a boundary-aware way to avoid padding
#if BOUNDARY_VECTOR_SIZE != VECTOR_SIZE
            const bool at_channel_boundary = get_global_id(0) == 0;
            if(at_channel_boundary)
            {
                VSTORE_PARTIAL(VECTOR_SIZE, BOUNDARY_VECTOR_SIZE)
                (values0, 0, (__global DATA_TYPE *)(output_ptr) + i * (int)SRC_DEPTH);
            }
            else // at_channel_boundary
#endif           // BOUNDARY_VECTOR_SIZE != VECTOR_SIZE
            {
                VSTORE(VECTOR_SIZE)
                (values0, 0, (__global DATA_TYPE *)(output_ptr) + i * (int)SRC_DEPTH);
            }
            i++;
        }
    }

#ifdef HAS_BIAS
    // We can use VECTOR_SIZE instead of BOUNDARY_VECTOR_SIZE even if it's at the boundary. This is because the bias is
    // added at the end of the channel, while the boundary vec is at the beginning of the channel.
    // The only case where the boundary vec is at the end of the channel is when there's only a single boundary vec in
    // the whole channel dimension, but in that case VECTOR_SIZE is also equal to BOUNDARY_VECTOR_SIZE
    // See the value of num_elems_processed_per_iteration in configure_opencl_kernel method in CLIm2ColKernel.cpp
    if((ch + VECTOR_SIZE) >= SRC_DEPTH)
    {
        *((__global DATA_TYPE *)(output_ptr) - ch + SRC_DEPTH * KERNEL_WIDTH * KERNEL_HEIGHT) = 1.0f;
    }
#endif // HAS_BIAS
}
#endif // defined(IM2COL_GENERIC)