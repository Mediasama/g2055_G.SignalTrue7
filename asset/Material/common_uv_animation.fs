#version 100

uniform sampler2D texSampler;
uniform highp float runtime;
uniform mediump vec2 speed;

varying mediump vec4 color;
varying mediump vec2 texCoord;

void main(void)
{
	mediump vec2 offset;
	offset.x =  fract(speed.x * runtime);
	offset.y =  fract(speed.y * runtime);
	mediump vec4 textureColor = texture2D(texSampler, texCoord + offset);
	gl_FragColor = textureColor * color;
}