////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// SHA1Hash
////////////////////////////////////////////////////////////////////////////////////////////////////

// SHA1 state during hashing.
class SHA1State
{
	u8[64] data;
	u32    datalen;
	u64    bitlen;
	u32[5] state;
	u32[4] k;

	void constructor()
	{
		reset();
	}

	// Reset state.
	void reset()
	{
		this.datalen = 0;
		this.bitlen = 0;
		this.state[0] = 0x67452301;
		this.state[1] = 0xEFCDAB89;
		this.state[2] = 0x98BADCFE;
		this.state[3] = 0x10325476;
		this.state[4] = 0xC3D2E1F0;
		this.k[0] = 0x5A827999;
		this.k[1] = 0x6ED9EBA1;
		this.k[2] = 0x8F1BBCDC;
		this.k[3] = 0xCA62C1D6;
	}
}

// SHA-1 implementation. 160 bit hash result. See http://csrc.nist.gov/publications/PubsFIPS.html
// Portions of this code adapted from Brad Conte https://github.com/B-Con/crypto-algorithms/
class SHA1Hash
{
	u32[] m = u32[](80); // temp state

	void constructor()
	{
		
	}

	u32 ROTLEFT(u32 a, u32 b) { return ((a << b) | (a >> (32 - b))); }

	// Hash data. Returuns hash in vector of bytes (160 bits total).
	u8[20] hash(ByteArray data)
	{
		SHA1State ctx();
		sha1Update(ctx, data);
		u8[20] hashVal = sha1Final(ctx);

		return hashVal;
	}

	// First pass.
	void sha1Update(SHA1State ctx, ByteArray data)
	{
		for(u64 i=0; i<data.numUsed; i++)
		{
			ctx.data[ctx.datalen] = data[i];
			ctx.datalen++;
			if(ctx.datalen == 64)
			{
				sha1Transform(ctx, ctx.data);
				ctx.bitlen += 512;
				ctx.datalen = 0;
			}
		}
	}

	// Hash bytes.
	void sha1Transform(SHA1State ctx, u8[64] data)
	{
		u32 a;
		u32 b;
		u32 c;
		u32 d;
		u32 e;
		u32 i;
		u32 j;
		u32 t;

		i = 0;
		j = 0;
		while(i < 16)
		{
			u32[4] tempData = u32(data[j], data[j + 1], data[j + 2], data[j + 3]);
			m[i] = (tempData[0] << 24) + (tempData[1] << 16) + (tempData[2] << 8) + (tempData[3]);

			i++;
			j += 4;
		}

		while(i < 80)
		{
			m[i] = (m[i - 3] ^ m[i - 8] ^ m[i - 14] ^ m[i - 16]);
			m[i] = (m[i] << 1) | (m[i] >> 31);

			i++;
		}

		a = ctx.state[0];
		b = ctx.state[1];
		c = ctx.state[2];
		d = ctx.state[3];
		e = ctx.state[4];

		for(i = 0; i<20; i++)
		{
			t = ROTLEFT(a, 5) + ((b & c) ^ (~b & d)) + e + ctx.k[0] + m[i];
			e = d;
			d = c;
			c = ROTLEFT(b, 30);
			b = a;
			a = t;
		}

		for(i = i; i<40; i++)
		{
			t = ROTLEFT(a, 5) + (b ^ c ^ d) + e + ctx.k[1] + m[i];
			e = d;
			d = c;
			c = ROTLEFT(b, 30);
			b = a;
			a = t;
		}

		for(i = i; i<60; i++)
		{
			t = ROTLEFT(a, 5) + ((b & c) ^ (b & d) ^ (c & d))  + e + ctx.k[2] + m[i];
			e = d;
			d = c;
			c = ROTLEFT(b, 30);
			b = a;
			a = t;
		}

		for(i = i; i<80; i++)
		{
			t = ROTLEFT(a, 5) + (b ^ c ^ d) + e + ctx.k[3] + m[i];
			e = d;
			d = c;
			c = ROTLEFT(b, 30);
			b = a;
			a = t;
		}

		ctx.state[0] += a;
		ctx.state[1] += b;
		ctx.state[2] += c;
		ctx.state[3] += d;
		ctx.state[4] += e;
	}

	// Final pass.
	u8[20] sha1Final(SHA1State ctx)
	{
		u32 i = ctx.datalen;

		// Pad whatever data is left in the buffer.
		if (ctx.datalen < 56)
		{
			ctx.data[i] = 0x80;
			i++;
			while (i < 56)
			{
				ctx.data[i] = 0x00;
				i++;
			}
		}
		else
		{
			ctx.data[i] = 0x80;
			i++;
			while (i < 64)
			{
				ctx.data[i] = 0x00;
				i++;
			}

			sha1Transform(ctx, ctx.data);

			for(u32 cc=0; cc<56; cc++) // memset(ctx.data, 0, 56);
				ctx.data[cc] = 0;
		}

		// Append to the padding the total message's length in bits and transform.
		ctx.bitlen  += ctx.datalen * 8;
		ctx.data[63] = ctx.bitlen;
		ctx.data[62] = ctx.bitlen >> 8;
		ctx.data[61] = ctx.bitlen >> 16;
		ctx.data[60] = ctx.bitlen >> 24;
		ctx.data[59] = ctx.bitlen >> 32;
		ctx.data[58] = ctx.bitlen >> 40;
		ctx.data[57] = ctx.bitlen >> 48;
		ctx.data[56] = ctx.bitlen >> 56;
		sha1Transform(ctx, ctx.data);

		// Since this implementation uses little endian byte ordering and MD uses big endian,
		// reverse all the bytes when copying the final state to the output hash.
		u8[20] hashVal;
		for(i=0; i<4; i++)
		{
			hashVal[i]      = (ctx.state[0] >> (24 - i * 8)) & 0x000000FF;
			hashVal[i + 4]  = (ctx.state[1] >> (24 - i * 8)) & 0x000000FF;
			hashVal[i + 8]  = (ctx.state[2] >> (24 - i * 8)) & 0x000000FF;
			hashVal[i + 12] = (ctx.state[3] >> (24 - i * 8)) & 0x000000FF;
			hashVal[i + 16] = (ctx.state[4] >> (24 - i * 8)) & 0x000000FF;
		}

		return hashVal;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// SHA256Hash
////////////////////////////////////////////////////////////////////////////////////////////////////

// SHA256 state during hash.
class SHA256State
{
	u8[64] data;
	u32    datalen;
	u64    bitlen;
	u32[8] state;

	void constructor()
	{
		reset();
	}

	// Reset state.
	void reset()
	{
		this.datalen  = 0;
		this.bitlen   = 0;
		this.state[0] = 0x6A09E667;
		this.state[1] = 0xBB67AE85;
		this.state[2] = 0x3C6EF372;
		this.state[3] = 0xA54FF53A;
		this.state[4] = 0x510E527F;
		this.state[5] = 0x9B05688C;
		this.state[6] = 0x1F83D9AB;
		this.state[7] = 0x5BE0CD19;
	}
}

// SHA-256 implementation. 256 bit hash result. See http://csrc.nist.gov/publications/PubsFIPS.html
// Portions of this code adapted from Brad Conte https://github.com/B-Con/crypto-algorithms/
class SHA256Hash
{
	shared u32[] k = u32[]( 0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5, 0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5, 
							0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3, 0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174, 
							0xE49B69C1, 0xEFBE4786, 0x0FC19DC6, 0x240CA1CC, 0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA, 
							0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7, 0xC6E00BF3, 0xD5A79147, 0x06CA6351, 0x14292967, 
							0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13, 0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85, 
							0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3, 0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070,
							0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5, 0x391C0CB3, 0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3,
							0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208, 0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2); // table of round constants

	u32[] m = u32[](64); // temp state

	u32 ROTLEFT(u32 a, u32 b) { return (((a) << (b)) | ((a) >> (32-(b)))); } // (((a) << (b)) | ((a) >> (32-(b))))
	u32 ROTRIGHT(u32 a, u32 b) { return (((a) >> (b)) | ((a) << (32-(b)))); } // (((a) >> (b)) | ((a) << (32-(b))))
	u32 CH(u32 x, u32 y, u32 z) { return (((x) & (y)) ^ (~(x) & (z))); }  // (((x) & (y)) ^ (~(x) & (z)))
	u32 MAJ(u32 x, u32 y, u32 z) { return (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z))); } // (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))
	u32 EP0(u32 x) { return (ROTRIGHT(x,2) ^ ROTRIGHT(x,13) ^ ROTRIGHT(x,22)); }  // (ROTRIGHT(x,2) ^ ROTRIGHT(x,13) ^ ROTRIGHT(x,22))
	u32 EP1(u32 x) { return (ROTRIGHT(x,6) ^ ROTRIGHT(x,11) ^ ROTRIGHT(x,25)); }  // (ROTRIGHT(x,6) ^ ROTRIGHT(x,11) ^ ROTRIGHT(x,25))
	u32 SIG0(u32 x) { return (ROTRIGHT(x,7) ^ ROTRIGHT(x,18) ^ ((x) >> 3)); }  // (ROTRIGHT(x,7) ^ ROTRIGHT(x,18) ^ ((x) >> 3))
	u32 SIG1(u32 x) { return (ROTRIGHT(x,17) ^ ROTRIGHT(x,19) ^ ((x) >> 10)); }  // (ROTRIGHT(x,17) ^ ROTRIGHT(x,19) ^ ((x) >> 10))

	// Hash data. Returns hash in vector of bytes (256 bits total).
	u8[32] hash(ByteArray data)
	{
		SHA256State ctx();
		sha256Update(ctx, data);
		u8[32] hashVal = sha256Final(ctx);

		return hashVal;
	}

	// First pass.
	void sha256Update(SHA256State ctx, ByteArray data)
	{
		for(u64 i=0; i<data.numUsed; i++)
		{
			ctx.data[ctx.datalen] = data[i];
			ctx.datalen++;
			if(ctx.datalen == 64)
			{
				sha256Transform(ctx, ctx.data);
				ctx.bitlen += 512;
				ctx.datalen = 0;
			}
		}
	}

	// Hash bytes.
	void sha256Transform(SHA256State ctx, u8[64] data)
	{
		u32 a;
		u32 b;
		u32 c;
		u32 d;
		u32 e;
		u32 f;
		u32 g;
		u32 h;
		u32 i;
		u32 j;
		u32 t1;
		u32 t2;

		i=0;
		j=0;
		while(i < 16)
		{
			u32[4] byteWords = u32(data[j], data[j + 1], data[j + 2], data[j + 3]);
			m[i] = (byteWords[0] << 24) | (byteWords[1] << 16) | (byteWords[2] << 8) | (byteWords[3]);

			i++;
			j += 4;
		}

		while(i < 64)
		{
			m[i] = SIG1(m[i - 2]) + m[i - 7] + SIG0(m[i - 15]) + m[i - 16];

			i++;
		}

		a = ctx.state[0];
		b = ctx.state[1];
		c = ctx.state[2];
		d = ctx.state[3];
		e = ctx.state[4];
		f = ctx.state[5];
		g = ctx.state[6];
		h = ctx.state[7];

		i = 0;
		while(i < 64)
		{
			t1 = h + EP1(e) + CH(e, f, g) + k[i] + m[i];
			t2 = EP0(a) + MAJ(a, b, c);
			h = g;
			g = f;
			f = e;
			e = d + t1;
			d = c;
			c = b;
			b = a;
			a = t1 + t2;

			i++;
		}

		ctx.state[0] += a;
		ctx.state[1] += b;
		ctx.state[2] += c;
		ctx.state[3] += d;
		ctx.state[4] += e;
		ctx.state[5] += f;
		ctx.state[6] += g;
		ctx.state[7] += h;
	}

	// Final pass.
	u8[32] sha256Final(SHA256State ctx)
	{
		u32 i = ctx.datalen;

		// Pad whatever data is left in the buffer.
		if(ctx.datalen < 56)
		{
			ctx.data[i] = 0x80;
			i++;
			while(i < 56)
			{
				ctx.data[i] = 0x00;
				i++;
			}
		}
		else
		{
			ctx.data[i] = 0x80;
			i++;
			while(i < 64)
			{
				ctx.data[i] = 0x00;
				i++;
			}

			sha256Transform(ctx, ctx.data);

			for(u32 cc=0; cc<56; cc++) // memset(ctx.data, 0, 56);
				ctx.data[cc] = 0;
		}

		// Append to the padding the total message's length in bits and transform.
		ctx.bitlen  += ctx.datalen * 8;
		ctx.data[63] = ctx.bitlen;
		ctx.data[62] = ctx.bitlen >> 8;
		ctx.data[61] = ctx.bitlen >> 16;
		ctx.data[60] = ctx.bitlen >> 24;
		ctx.data[59] = ctx.bitlen >> 32;
		ctx.data[58] = ctx.bitlen >> 40;
		ctx.data[57] = ctx.bitlen >> 48;
		ctx.data[56] = ctx.bitlen >> 56;
		
		sha256Transform(ctx, ctx.data);

		// Since this implementation uses little endian byte ordering and SHA uses big endian,
		// reverse all the bytes when copying the final state to the output hash.
		u8[32] hashVal;
		for(i=0; i<4; i++)
		{
			hashVal[i]      = (ctx.state[0] >> (24 - i * 8)) & 0x000000FF;
			hashVal[i + 4]  = (ctx.state[1] >> (24 - i * 8)) & 0x000000FF;
			hashVal[i + 8]  = (ctx.state[2] >> (24 - i * 8)) & 0x000000FF;
			hashVal[i + 12] = (ctx.state[3] >> (24 - i * 8)) & 0x000000FF;
			hashVal[i + 16] = (ctx.state[4] >> (24 - i * 8)) & 0x000000FF;
			hashVal[i + 20] = (ctx.state[5] >> (24 - i * 8)) & 0x000000FF;
			hashVal[i + 24] = (ctx.state[6] >> (24 - i * 8)) & 0x000000FF;
			hashVal[i + 28] = (ctx.state[7] >> (24 - i * 8)) & 0x000000FF;
		}

		return hashVal;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Hashing
////////////////////////////////////////////////////////////////////////////////////////////////////

// A small selection of standard secure hashing algorithms.
class Hashing
{
	const u8 HASH_NULL   = 0; // Always returns null / empty string.
	const u8 HASH_SHA1   = 1; // Known to be insecure (collisions). Provided for backwards compatibility only.
	const u8 HASH_SHA256 = 2; // SHA2-256.
	const u8 HASH_SHA384 = 3; // SHA2-384. TODO implement
	const u8 HASH_SHA512 = 4; // SHA2-512. TODO implement

	// Hash raw bytes using SHA-256 etc. Returns hash as raw bytes.
	shared u8[] hash(ByteArray bytes, u8 hashAlgo)
	{
		u8[] hashBytes = null;

		if(hashAlgo == HASH_NULL)
		{
			hashBytes = u8[](0);
		}
		else if(hashAlgo == HASH_SHA1)
		{
			u8[20] hashValSHA1 = hashSHA1(bytes);
			hashBytes = u8[](20);

			for(u8 d=0; d<20; d++)
				hashBytes[d] = hashValSHA1[d];
		}
		else if(hashAlgo == HASH_SHA256)
		{
			u8[32] hashValSHA256 = hashSHA256(bytes);
			hashBytes = u8[](32);

			for(u8 d=0; d<32; d++)
				hashBytes[d] = hashValSHA256[d];
		}

		return hashBytes;
	}

	// Hash raw bytes using SHA-256 etc. Returns hash as raw bytes.
	shared u8[] hash(u8[] bytes, u8 hashAlgo)
	{
		return hash(ByteArray(bytes), hashAlgo);
	}

	// Hash raw bytes of String SHA-256 etc. Returns raw hash bytes.
	shared u8[] hash(String<u8> str, u8 hashAlgo)
	{
		u8[] bytes(str.length());
		for(u64 s=0; s<str.length(); s++)
			bytes[s] = str.chars[s];

		u8[] res = hash(bytes, hashAlgo);

		return res;
	}

	// Hash using SHA-1. Returns 20 byte (160 bit) hash value.
	shared u8[20] hashSHA1(ByteArray bytes)
	{
		SHA1Hash hasher();
		u8[20] hashVal = hasher.hash(bytes);
		return hashVal;
	}

	// Hash using SHA-256. Returns 32 byte (256 bit) hash value.
	shared u8[32] hashSHA256(ByteArray bytes)
	{
		SHA256Hash hasher();
		u8[32] hashVal = hasher.hash(bytes);
		return hashVal;
	}

	// Hash data bytes using SHA-256 etc. Returns hash as common hex (4 bit per char) string.
	shared String<u8> hashToHexStr(ByteArray data, u8 hashAlgo)
	{
		if(hashAlgo == HASH_NULL)
		{
			return String<u8>("");
		}
		else if(hashAlgo == HASH_SHA1)
		{
			u8[20] hashValSHA1 = hashSHA1(data);
			String<u8> str(40);

			for(u8 d=0; d<20; d++)
			{
				str.append(String<u8>:formatNumberHex(hashValSHA1[d]));
			}

			str.toLowercase(); // hash strings are normally presented in hex lowercase.

			return str;
		}
		else if(hashAlgo == HASH_SHA256)
		{
			u8[32] hashValSHA256 = hashSHA256(data);
			String<u8> str(64);

			for(u8 d=0; d<32; d++)
			{
				str.append(String<u8>:formatNumberHex(hashValSHA256[d]));
			}

			str.toLowercase(); // hash strings are normally presented in hex lowercase.

			return str;
		}

		return String<u8>("");
	}

	// Hash string bytes using SHA-256 etc. Returns hash as common hex (4 bit per char) string.
	shared String<u8> hashToHexStr(String<u8> str, u8 hashAlgo)
	{
		ByteArray data(str);
		return hashToHexStr(data, hashAlgo);
	}
}
