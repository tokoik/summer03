#version 120

// simple.vert

invariant gl_Position;
attribute vec2 position;
uniform mat4 projectionMatrix;

void main(void)
{
  gl_Position = projectionMatrix * vec4(position, 0.0, 1.0);
}
