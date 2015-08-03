//*********************************************************
//
// Copyright (c) Microsoft. All rights reserved.
// This code is licensed under the MIT License (MIT).
// THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
// IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
// PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
//
//*********************************************************

cbuffer ConstantBuffer : register(b0)
{
    float2 screensize;
};

struct SortedColorItem
{
    float4 color;
    float depth;
};

struct BufferInput
{
    SortedColorItem colorItems[8];
    float isUsed;
};

RWStructuredBuffer <BufferInput> mybuf : register(u1);

struct PSInput
{
	float4 position : SV_POSITION;
	float4 color : COLOR;
};

PSInput VSMain(float4 position : POSITION, float4 color : COLOR)
{
	PSInput result;

	result.position = position;
	result.color = color;

	return result;
}

float4 PSMain(PSInput input) : SV_TARGET
{
    float texBufferCoord = screensize[0] * input.position.y + input.position.x;

    BufferInput newInput = mybuf[texBufferCoord];

    float gColor;

    if ( newInput.isUsed == 0.0f )
    {
        newInput.isUsed = 1.0;
        newInput.colorItems[0].color.x++;

        gColor = 1.0f;
    }
    else
    {
        newInput.isUsed = 0.0f;

        gColor = 0.0f;
    }

    mybuf[texBufferCoord] = newInput;

    float red = input.position.x / screensize[0];

	return float4(red, gColor, ( newInput.colorItems[0].color.x / 50.0f ) % 1.0f, 1.0);
}
