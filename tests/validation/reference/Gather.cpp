/*
 * Copyright (c) 2018-2019, 2022 Arm Limited.
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

#include "Gather.h"

#include "arm_compute/core/Types.h"
#include "arm_compute/core/utils/misc/ShapeCalculator.h"
#include "tests/validation/Helpers.h"

namespace arm_compute
{
namespace test
{
namespace validation
{
namespace reference
{
template <typename T>
SimpleTensor<T> gather(const SimpleTensor<T> &src, const SimpleTensor<uint32_t> &indices, uint32_t actual_axis)
{
    const auto       *indices_ptr = static_cast<const uint32_t *>(indices.data());
    const TensorShape dst_shape   = arm_compute::misc::shape_calculator::compute_gather_shape(src.shape(), indices.shape(), actual_axis);
    SimpleTensor<T>   dst(dst_shape, src.data_type());

    Window win;
    win.use_tensor_dimensions(dst_shape);
    if(indices.shape().num_dimensions() == 1u)
    {
        execute_window_loop(win, [&](const Coordinates & id)
        {
            Coordinates offset;
            for(unsigned int dim = 0; dim < id.num_dimensions(); ++dim)
            {
                if(dim == actual_axis)
                {
                    offset.set(dim, indices_ptr[id[dim]]);
                }
                else
                {
                    offset.set(dim, id[dim]);
                }
            }
            *reinterpret_cast<T *>(dst(id)) = *reinterpret_cast<const T *>(src(offset));
        });
    }
    else
    {
        if(actual_axis == 1)
        {
            win.set(Window::DimX, Window::Dimension(0, 1, 1));
            execute_window_loop(win, [&](const Coordinates & id)
            {
                auto       *dst_ptr = dst(id);
                Coordinates index_offset;
                for(uint32_t k = 0; k < indices.shape().num_dimensions(); ++k)
                {
                    index_offset.set(k, id[k + 1]);
                }
                const uint32_t row = *reinterpret_cast<const uint32_t *>(indices(index_offset));
                Coordinates    src_offset;
                src_offset.set(0, 0);
                src_offset.set(1, row);
                for(uint32_t j = 2; j < src.shape().num_dimensions(); ++j)
                {
                    src_offset.set(j, id[1 + indices.shape().num_dimensions() + (j - 2)]);
                }
                const auto in_ptr_row = src(src_offset);
                memcpy(dst_ptr, in_ptr_row, src.shape()[0] * src.element_size());
            });
        }
        else
        {
            ARM_COMPUTE_ERROR("Not implemented.");
        }
    }

    return dst;
}

template SimpleTensor<float> gather(const SimpleTensor<float> &src, const SimpleTensor<uint32_t> &indices, uint32_t actual_axis);
template SimpleTensor<half> gather(const SimpleTensor<half> &src, const SimpleTensor<uint32_t> &indices, uint32_t actual_axis);
template SimpleTensor<uint16_t> gather(const SimpleTensor<uint16_t> &src, const SimpleTensor<uint32_t> &indices, uint32_t actual_axis);
template SimpleTensor<uint8_t> gather(const SimpleTensor<uint8_t> &src, const SimpleTensor<uint32_t> &indices, uint32_t actual_axis);
} // namespace reference
} // namespace validation
} // namespace test
} // namespace arm_compute
