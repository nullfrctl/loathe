#include "CIE_1931.fxh"
#include "loathe.fxh"

/* Go show Michał e love: https://mina86.com/2019/srgb-xyz-matrix/.
 * This blog post was the source of a lot of info. */

namespace loathe {
  namespace CSC {
    namespace chromaticities {
      static const float3x3 Rec709_xyY = float3x3(0.64, 0.33, 0.2126,
                                                  0.30, 0.60, 0.7152,
                                                  0.15, 0.06, 0.0722);

      static const float4x2 Rec709_xy = float4x2(0.64, 0.33,
                                                 0.30, 0.60,
                                                 0.15, 0.06,
                                                 CIE_1931::std_illuminants::D65);

      float3x3 xy_to_xyY(float4x2 coords_xy) {
        float3 white_XYZ = CIE_1931::xyY_to_XYZ(float3(coords_xy[3], 1.0));

        // xc/yc
        float3 X_prime = float3(coords_xy[0].x / coords_xy[0].y,
                                coords_xy[1].x / coords_xy[1].y,
                                coords_xy[2].x / coords_xy[2].y);

        // (1 - xc - yc) / yc
        float3 Z_prime = float3(CIE_1931::xy_to_z(coords_xy[0]) / coords_xy[0].y,
                                CIE_1931::xy_to_z(coords_xy[1]) / coords_xy[1].y,
                                CIE_1931::xy_to_z(coords_xy[2]) / coords_xy[2].y);

        float3x3 M_prime = float3x3(X_prime, float3(1, 1, 1), Z_prime);
        float3 Y = mul(std::inverse(M_prime), white_XYZ);

        float3x3 coords_xyY = float3x3(coords_xy[0], Y.r,
                                       coords_xy[1], Y.g,
                                       coords_xy[2], Y.b);

        return coords_xyY;
      }
    } // namespace chromaticities

    namespace matrices {
      static const float3x3 Rec709_to_XYZ = float3x3(0.4124, 0.3576, 0.1805,
                                                     0.2126, 0.7152, 0.0722,
                                                     0.0193, 0.1192, 0.9505);

      static const float3x3 XYZ_to_Rec709 = float3x3(+3.2406, -1.5372, -0.4986,
                                                     -0.9689, +1.8758, +0.0415,
                                                     +0.0557, -0.2040, +1.0570);
    } // namespace matrices

    /* derive RGB to XYZ matrix using color space chromaticities with xyY (not
     * just xy). I have no idea why this works but it does. */
    float3x3 RGB_to_XYZ_mat(float3x3 coords_xyY) {
      float3x3 M;
      M[0] = CIE_1931::xyY_to_XYZ(coords_xyY[0]);
      M[1] = CIE_1931::xyY_to_XYZ(coords_xyY[1]);
      M[2] = CIE_1931::xyY_to_XYZ(coords_xyY[2]);

      return transpose(M);
    }

    float3x3 RGB_to_XYZ_mat(float4x2 coords_xy) {
      float3 white_XYZ = CIE_1931::xyY_to_XYZ(float3(coords_xy[3], 1.0));

      // xc/yc
      float3 X_prime = float3(coords_xy[0].x / coords_xy[0].y,
                              coords_xy[1].x / coords_xy[1].y,
                              coords_xy[2].x / coords_xy[2].y);

      // (1 - xc - yc) / yc
      float3 Z_prime = float3(CIE_1931::xy_to_z(coords_xy[0]) / coords_xy[0].y,
                              CIE_1931::xy_to_z(coords_xy[1]) / coords_xy[1].y,
                              CIE_1931::xy_to_z(coords_xy[2]) / coords_xy[2].y);

      float3x3 M_prime = float3x3(X_prime, float3(1, 1, 1), Z_prime);
      float3 Y = mul(std::inverse(M_prime), white_XYZ);

      return mul(M_prime, std::diag(Y));
    }
  } // namespace CSC
} // namespace loathe