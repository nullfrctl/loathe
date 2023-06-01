// SPDX-License-Identifier: CC-BY-NC-SA-4.0+

#pragma once
#include "ReShade.fxh"
#include "ReShadeUI.fxh"

#define NULL (0)
#define TINY (1e-8)

#define where(_c, _x, _y) ((_c) ? (_x) : (_y))

namespace loathe {
  texture2D backbuffer_texture : color;
  texture2D depthbuffer_texture : depth;

  sampler2D backbuffer { Texture = backbuffer_texture; };
  sampler2D depthbuffer { Texture = depthbuffer_texture; };

  struct vs_t {
    float4 position : sv_position;
    float2 texcoord : texcoord;
  };

  vs_t vs_quad(uint id : sv_vertexid) {
    vs_t vs;

    vs.texcoord.x = id == 2 ? 2.0 : 0.0;
    vs.texcoord.y = id == 1 ? 2.0 : 0.0;
    vs.position = float4(vs.texcoord * float2(+2, -2) + float2(-1, +1), 0, 1);

    return vs;
  }
} // namespace loathe
