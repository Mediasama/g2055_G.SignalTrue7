#version 100

uniform sampler2D texSampler;
uniform mediump vec2 scrollingSpeed;
uniform highp float runtime;

varying mediump vec4 color;
varying mediump vec2 texCoord;

void main(void)
{
	mediump vec2 offset;
    offset.x = fract(scrollingSpeed.x * runtime);
    offset.y = fract(scrollingSpeed.y * runtime);
    mediump vec4 textureColor = texture2D(texSampler, texCoord + offset);

	gl_FragColor = textureColor * color;
}