 ////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class BigIntCreateTests implements IUnitTest
{
	void run()
	{
		// create from small numbers

        BigInt a(u64(0));
		test(a.numUsed == 1);
		test(a.numbers != null);
		test(a.numbers[0] == 0);
		test(a.sign == 1);

		BigInt b(u64(1));
		test(b.numUsed == 1);
		test(b.numbers != null);
		test(b.numbers[0] == 1);
		test(b.sign == 1);

		BigInt c(u64(123456));
		test(c.numUsed == 1);
		test(c.numbers != null);
		test(c.numbers[0] == 123456);
		test(c.sign == 1);

		BigInt d(i64(-123456));
		test(d.numUsed == 1);
		test(d.numbers != null);
		test(d.numbers[0] == 123456);
		test(d.sign == -1);

		BigInt e = BigInt(-217);
		test(e.sign == -1);
		test(e.asI64() == -217);
	}
}

class BigIntSetBitTests implements IUnitTest
{
	void run()
	{
        BigInt a(u64(0));
		a.setBit(0, 1);
		test(a.asU64() == 1);
		
		BigInt b("0", 10);
		b.setBit(1, 1);
		test(b.asU64() == 2);

		BigInt c("1", 10);
		c.setBit(1, 1);
		test(c.asU64() == 3);

		BigInt d("1", 10);
		d.setBit(32, 1);
		test(d.asU64() == 0b100000000000000000000000000000001);
	}
}

class BigIntSplitTests implements IUnitTest
{
	void run()
	{
		// split 72 bits into 72 and 10 bit numbers.
        BigInt a("0b10001111 00110011 10101010 00110000 11111100 00111101 10011111 11010010 11001010"); // 72 bits
		test(a.getBitLength() == 72);

		BigInt hi();
		BigInt low();

		a.split(hi, low, 10);

		test(hi.getBitLength() == 72);
		test(hi.equals(BigInt("0b10001111 00110011 10101010 00110000 11111100 00111101 10011111 11010000 00000000")) == true);

		test(low.getBitLength() == 10);
		test(low.equals(BigInt("0b1011001010")) == true);

		// Test split handles leading zeros in low properly
		a = BigInt("0b10001111 00110011 10101010 00110000 11111100 00111101 10011111 11010000 11001010"); // 72 bits
		test(a.getBitLength() == 72);
		a.split(hi, low, 10);

		test(hi.getBitLength() == 72);
		test(hi.equals(BigInt("0b10001111 00110011 10101010 00110000 11111100 00111101 10011111 11010000 00000000")) == true);

		test(low.getBitLength() == 8); // not 10 bits because bits 9/10 are zero in a
		test(low.equals(BigInt("0b11001010")) == true);
	}
}

class BigIntShiftTests implements IUnitTest
{
	void run()
	{
		// shift right
        BigInt a(u64(0));
		a.shiftRight(10);
		test(a.numUsed == 1);
		test(a.numbers != null);
		test(a.numbers[0] == 0);
		test(a.sign == 1);

		// shift right
        a = BigInt(u64(4));
		a.shiftRight(2);
		test(a.numUsed == 1);
		test(a.numbers != null);
		test(a.numbers[0] == 1);
		test(a.sign == 1);

		// shift right (preserve sign)
        a = BigInt(i64(-4));
		a.shiftRight(2);
		test(a.numUsed == 1);
		test(a.numbers != null);
		test(a.numbers[0] == 1);
		test(a.sign == -1);

		// shift right past 32 bit boundary
        a = BigInt(u64(4294967296));
		a.shiftRight(32);
		test(a.numUsed == 1);
		test(a.numbers != null);
		test(a.numbers[0] == 1);
		test(a.sign == 1);

		// shift left
		a = BigInt(u64(0));
		a.shiftLeft(10);
		test(a.numUsed == 1);
		test(a.numbers != null);
		test(a.numbers[0] == 0);
		test(a.sign == 1);

		// shift left
        a = BigInt(u64(1));
		a.shiftLeft(2);
		test(a.numUsed == 1);
		test(a.numbers != null);
		test(a.numbers[0] == 4);
		test(a.sign == 1);

		// shift left (preserve sign)
        a = BigInt(i64(-1));
		a.shiftLeft(2);
		test(a.numUsed == 1);
		test(a.numbers != null);
		test(a.numbers[0] == 4);
		test(a.sign == -1);

		// shift left past 32 bit boundary
        a = BigInt(u64(1));
		a.shiftLeft(32);
		test(a.numUsed == 2);
		test(a.numbers != null);
		test(a.numbers[0] == 0);
		test(a.numbers[1] == 1);
		test(a.sign == 1);

	}
}

class BigIntAddTests implements IUnitTest
{
	void run()
	{
		// add small numbers
        BigInt a(u64(0));
		BigInt b(u64(1));
		a.add(b);
		test(a.numUsed == 1);
		test(a.numbers != null);
		test(a.numbers[0] == 1);
		test(a.sign == 1);

		BigInt c(u64(1024));
		BigInt d(u64(30));
		c.add(d);
		test(c.numUsed == 1);
		test(c.numbers != null);
		test(c.numbers[0] == 1054);
		test(c.sign == 1);

		BigInt e(u64(1024));
		BigInt f(i64(-10));
		test(f.sign == -1);
		e.add(f);
		test(e.numUsed == 1);
		test(e.numbers != null);
		test(e.numbers[0] == 1014);
		test(e.sign == 1);

		BigInt g(i64(-1024));
		BigInt h(i64(-10));
		g.add(h);
		test(g.numUsed == 1);
		test(g.numbers != null);
		test(g.numbers[0] == 1034);
		test(g.sign == -1);

		// add large numbers (greater than U32_MAX)
		BigInt a1(u64(Math:U32_MAX));
		BigInt b1(u64(Math:U32_MAX));
		a1.add(b1);
		test(a1.numUsed == 2);
		test(a1.numbers != null);
		test(a1.numbers[0] == (Math:U32_MAX-1));
		test(a1.numbers[1] == 1);
		test(a1.sign == 1);
	}
}

class BigIntSubtractTests implements IUnitTest
{
	void run()
	{
		// subtract small numbers
        BigInt a(i64(10));
		BigInt b(i64(3));
		a.subtract(b);
		test(a.numUsed == 1);
		test(a.numbers != null);
		test(a.numbers[0] == 7);
		test(a.sign == 1);

		BigInt c(i64(3));
		BigInt d(i64(10));
		c.subtract(d);
		test(c.numUsed == 1);
		test(c.numbers != null);
		test(c.numbers[0] == 7);
		test(c.sign == -1);

		BigInt e(i64(-20));
		BigInt f(i64(-10));
		e.subtract(f);
		test(e.numUsed == 1);
		test(e.numbers != null);
		test(e.numbers[0] == 10);
		test(e.sign == -1);

		// subtract large numbers (greater than U32_MAX)
		BigInt a1(i64(Math:U32_MAX) * 2);
		BigInt b1(i64(Math:U32_MAX) - 2);
		a1.subtract(b1);
		test(a1.numUsed == 2);
		test(a1.numbers != null);
		test(a1.numbers[0] == 1);
		test(a1.numbers[1] == 1);
		test(a1.sign == 1);

		// subtract large numbers (greater than U32_MAX)
		BigInt a1(i64(Math:U32_MAX) + 1);
		test(a1.numUsed == 2);
		test(a1.numbers[0] == 0);
		test(a1.numbers[1] == 1);

		BigInt b1(i64(2147483648)); // half of 2^32
		a1.subtract(b1);
		test(a1.numUsed == 1);
		test(a1.numbers != null);
		test(a1.numbers[0] == 2147483648);
		test(a1.numbers[1] == 0);
		test(a1.sign == 1);

		//Log:log("BigIntSubtractTests after subtract a1[0] = " + String<u8>:formatNumber(a1.numbers[0]) + "\n");
		//Log:log("BigIntSubtractTests after subtract a1[1] = " + String<u8>:formatNumber(a1.numbers[1]) + "\n");
	}
}

class BigIntMultiplyTests implements IUnitTest
{
	void run()
	{
		// multiply small numbers
        BigInt a(i64(10));
		BigInt b(i64(3));
		a.multiply(b);
		test(a.numUsed == 1);
		test(a.numbers != null);
		test(a.numbers[0] == 30);
		test(a.sign == 1);

		BigInt c(i64(3));
		BigInt d(i64(-11));
		c.multiply(d);
		test(c.numUsed == 1);
		test(c.numbers != null);
		test(c.numbers[0] == 33);
		test(c.sign == -1);

		BigInt e(i64(-20));
		BigInt f(i64(-10));
		e.multiply(f);
		test(e.numUsed == 1);
		test(e.numbers != null);
		test(e.numbers[0] == 200);
		test(e.sign == 1);

		// multiply large numbers (greater than U32_MAX)
		BigInt a1(i64(Math:U32_MAX) + 1);
		BigInt b1(i64(2));
		a1.multiply(b1);
		test(a1.numUsed == 2);
		test(a1.numbers != null);
		test(a1.numbers[0] == 0);
		test(a1.numbers[1] == 2);
		test(a1.sign == 1);

		// multiply self
		BigInt x("100000000000000");
		x.multiply(x);
		test(x.equals(BigInt("10000000000000000000000000000")) == true);
	}
}

class BigIntPowerTests implements IUnitTest
{
	void run()
	{
		// special cases
		BigInt base();
		BigInt exp();

		// 0^0 == 1
		base.set(0);
		exp.set(0);
		base.power(exp);
		test(base.numUsed == 1);
		test(base.numbers[0] == 1);

		// 0^1 == 0
		base.set(0);
		exp.set(1);
		base.power(exp);
		test(base.numUsed == 1);
		test(base.numbers[0] == 0);

		// n^0 == 1
        base.set(2);
		exp.set(0);
		base.power(exp);
		test(base.numUsed == 1);
		test(base.numbers[0] == 1);

		// n^1 == n
		base.set(3);
		exp.set(1);
		base.power(exp);
		test(base.numUsed == 1);
		test(base.numbers[0] == 3);

		// normal path small numbers

		// 3^2 = 9
		base.set(3);
		exp.set(2);
		base.power(exp);
		//Log:log("BigIntPowerTests 3^2 = " + base.toString() + "\n");
		test(base.numUsed == 1);
		test(base.numbers[0] == 9);
		
		// 10^3 = 1000
		base.set(10);
		exp.set(3);
		base.power(exp);
		//Log:log("BigIntPowerTests 10^3 = " + base.toString() + "\n");
		test(base.numUsed == 1);
		test(base.numbers[0] == 1000);

		// 13^4 = 28561
		base.set(13);
		exp.set(4);
		base.power(exp);
		//Log:log("BigIntPowerTests 13^4 = " + base.toString() + "\n");
		test(base.numUsed == 1);
		test(base.numbers[0] == 28561);

		// normal path large result numbers

		// 10382^5 = 120616055792925662432
		base.setFromBase10String("10382");
		exp.setFromBase10String("5");
		base.power(exp);
		//Log:log("BigIntPowerTests 10382^5 = " + base.toString() + "\n");
		test(base.equals(BigInt("120616055792925662432")) == true);
	}
}

class BigIntDivideTests implements IUnitTest
{
	void run()
	{
		// divide small numbers
        BigInt a(i64(12));
		BigInt b(i64(3));
		a.divide(b);
		test(a.numUsed == 1);
		test(a.numbers != null);
		test(a.numbers[0] == 4);
		test(a.sign == 1);

		BigInt c(i64(15));
		BigInt d(i64(15));
		c.divide(d);
		test(c.numUsed == 1);
		test(c.numbers != null);
		test(c.numbers[0] == 1);
		test(c.sign == 1);

		BigInt e(i64(15));
		BigInt f(i64(11));
		e.divide(f);
		test(e.numUsed == 1);
		test(e.numbers != null);
		test(e.numbers[0] == 1);
		test(e.sign == 1);

		BigInt e(i64(11));
		BigInt f(i64(15));
		e.divide(f);
		test(e.numUsed == 1);
		test(e.numbers != null);
		test(e.numbers[0] == 0);
		test(e.sign == 1);

		// divide large numbers (greater than U32_MAX)
		BigInt a1(i64(Math:U32_MAX) + 1); // 2^32
		BigInt b1(i64(2048));
		a1.divide(b1);
		test(a1.numUsed == 1);
		test(a1.numbers != null);
		test(a1.numbers[0] == 2097152);
		test(a1.numbers[1] == 0);
		test(a1.sign == 1);

		// larger numbers (128 bit divided by 64 bit number)
		BigInt a("0xFABCDEF4568901927489AABB7839AB64"); // 128 bit
		BigInt b("0x7111AA221139AB64"); // ~64 bit
		test(a.getBitLength() == 128);
		a.divide(b);
		test(a.toString(16).compare("237B24A6272EA3CFF") == true);
	}
}

class BigIntDivide2Tests implements IUnitTest
{
	void run()
	{
		BigInt a2048bit("0xE234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD"); 
		BigInt b128bit("0xFABCDEF4568901927489AABB7839AB64");
		
		BigInt a();
		BigInt b();

		// test special bugs
		
        BigInt a0("0xFABCDEF4568901927489AABB7839AB64"); // 128 bit
		BigInt b0("0x7111AA221139AB64"); // ~64 bit
		test(a0.getBitLength() == 128);

		a = BigInt(a0);
		b = BigInt(b0);

		f64 startTime = System:getTime();
		for(u32 x=0; x<1000; x++)
		{
			a.copy(a0);
			a.divide(b);
		}
		f64 elapsedTime = System:getTime() - startTime;

		test(a.toString(16).compare("237B24A6272EA3CFF") == true);

		//Log:log("BigIntTempTests a / b x1000 time: " + String<u8>:formatNumber(elapsedTime) + " ms \n");

		// Performance log:
		// BigIntTempTests a / b x1000 time: 697.45 ms | Baseline
		// BigIntTempTests a / b x1000 time:  42.59 ms | Using bit-shift power of 2, in lieu of inner loop to double until divisor same bit length
		// BigIntTempTests a / b x1000 time:  46.32 ms | After fixes to absDifference()
		// BigIntTempTests a / b x1000 time:  51.41 ms 

		// 2048 bit divide test
		f64 startTime = System:getTime();
		for(u32 x=0; x<10; x++)
		{
			a.copy(a2048bit);
			a.divide(b128bit);
		}
		f64 elapsedTime = System:getTime() - startTime;
		//Log:log("BigIntTempTests a / b 2048bit x10 time: " + String<u8>:formatNumber(elapsedTime) + " ms \n");

		// 2048 / 128 bit divide test
		// BigIntTempTests a / b 2048bit x10 time: FAIL      | Baseline
		// BigIntTempTests a / b 2048bit x10 time: 28.47 ms  | Using bit-shift power of 2
		// BigIntTempTests a / b 2048bit x10 time: 30.36 ms  | After fixes to absDifference()
		// BigIntTempTests a / b 2048bit x10 time: 31.90 ms 
	}
}

class BigIntModuloTests implements IUnitTest
{
	void run()
	{
		// Modulo small numbers
        BigInt a(i64(12));
		BigInt b(i64(3));
		a.modulo(b);
		test(a.isZero() == true);

		BigInt c(i64(17));
		BigInt d(i64(15));
		c.modulo(d);
		test(c.numUsed == 1);
		test(c.numbers != null);
		test(c.numbers[0] == 2);
		test(c.sign == 1);

		BigInt e(i64(36));
		BigInt f(i64(10));
		e.modulo(f);
		test(e.numUsed == 1);
		test(e.numbers != null);
		test(e.numbers[0] == 6);
		test(e.sign == 1);

		// Modulo large numbers (greater than U32_MAX)
		BigInt a1(i64(Math:U32_MAX) + 1 + 7); // 2^32
		BigInt b1(i64(2048));
		a1.modulo(b1);
		test(a1.numUsed == 1);
		test(a1.numbers != null);
		test(a1.numbers[0] == 7);
		test(a1.numbers[1] == 0);
		test(a1.sign == 1);

		BigInt x(2214878997);
		BigInt y(10);
		x.modulo(y);
		test(x.numUsed == 1);
		test(x.numbers[0] == 7);

		BigInt x1("3892129012982873783737487498392214878993");
		BigInt y1(10);
		x1.modulo(y1);
		test(x1.numUsed == 1);
		test(x1.numbers[0] == 3);
	}
}

class BigIntModuloPowerTests implements IUnitTest
{
	void run()
	{
		// special cases
		BigInt base();
		BigInt exp();
		BigInt mod();

		// 10^3 % 1 == 0
		base.set(10);
		exp.set(3);
		mod.set(1);
		base.moduloPower(exp, mod);
		test(base.numUsed == 1);
		test(base.numbers[0] == 0);

		// normal path small numbers

		// 3^2 % 4 = 1
		base.set(3);
		exp.set(2);
		mod.set(4);
		base.moduloPower(exp, mod);
		test(base.numUsed == 1);
		test(base.numbers[0] == 1);
		
		// 10^3 % 11 = 10
		base.set(10);
		exp.set(3);
		mod.set(11);
		base.moduloPower(exp, mod);
		test(base.numUsed == 1);
		test(base.numbers[0] == 10);

		// 13^4 mod 37 = 34
		base.set(13);
		exp.set(4);
		mod.set(37);
		base.moduloPower(exp, mod);
		test(base.numUsed == 1);
		test(base.numbers[0] == 34);

		// normal path large result numbers

		// 10382^5 % 387 = 245
		base.setFromBase10String("10382");
		exp.setFromBase10String("5");
		mod.set(387);
		base.moduloPower(exp, mod);
		test(base.equals(BigInt("245")) == true);
	}
}

class BigIntSqrtTests implements IUnitTest
{
	void run()
	{
		BigInt a();
		a.set(9);
		a.sqrt();
		test(a.numUsed == 1);
		test(a.numbers[0] == 3); // exact 3

		a.set(1026);
		a.sqrt();
		test(a.numUsed == 1);
		test(a.numbers[0] == 32); // ~32.03

		// larger number (small, floor root)
		a.setFromBase10String("192437847437482892928383874");
		a.sqrt();
		test(a.equals(BigInt("13872196921810")) == true); 

		// 192437847437 474839253676100 = 13872196921810 * 13872196921810 (less than)
		// 192437847437 482892928383874 = original number
		// 192437847437 502583647519721 = 13872196921811 * 13872196921811 (more than)

		// larger number (large, ceil root)
		a.setFromBase10String("192437847437482892928383874");
		a.sqrt(true); // guarantee to give us larger root
		test(a.equals(BigInt("13872196921811")) == true);
	}
}

class BigIntGCDTests implements IUnitTest
{
	void run()
	{
		BigInt a(96);
		BigInt b(1024);
		a.greatestCommonDivisor(b);
		test(a.equals(32));
	}
}

class BigIntGCDExtendedTests implements IUnitTest
{
	void run()
	{
		BigInt x();
		BigInt y();

		BigInt a(25);
		BigInt b(60);
		BigInt r = a.greatestCommonDivisorExtended(a, b, x, y);
		test(r.equals(5));

		a = BigInt("0xE420DED52FC76FE4E0AB6CEE1E340763"); // prime
		b = BigInt("0x6725B4D2377AE6E4BC7AF5D93EA57125"); // prime
		r = a.greatestCommonDivisorExtended(a, b, x, y);
		test(r.equals(1));

		a = BigInt("223134656123751459819751932999300002992"); // not prime
		b = BigInt("137106266038120309457922928888209939931"); // not prime
		r = a.greatestCommonDivisorExtended(a, b, x, y);
		test(r.equals(7));
	}
}

class BigIntModInvTests implements IUnitTest
{
	void run()
	{
		BigInt a(3);
		BigInt b(11);
		a.modInv(b);
		test(a.equals(4));

		a = BigInt(42);
		b = BigInt(2017);
		a.modInv(b);
		test(a.equals(1969));

		a = BigInt(40);
		b = BigInt(1);
		a.modInv(b);
		test(a.equals(0));

		a = BigInt(52);
		b = BigInt(-217);
		test(b.sign == -1);
		a.modInv(b);
		test(a.equals(96));

		a = BigInt(-486);
		b = BigInt(217);
		a.modInv(b);
		test(a.equals(121));

		a = BigInt(40);
		b = BigInt(2018);
		a.modInv(b);
		test(a.equals(-1)); // no inverse

		//Log:log("BigIntModInvTests() a as -1= " + a.toString(10) + "\n");

		// 128 bit numbers
		BigInt a1("0xE420DED52FC76FE4E0AB6CEE1E340763"); // base10: 303234656123751459819751939168806373219
		BigInt b1("0x6725B4D2377AE6E4BC7AF5D93EA57125"); // base10: 137106266038425163681432071025568608549
		BigInt temp(a1);
		temp.modInv(b1);
		test(temp.equals(BigInt("80304878568059106339100173465998353718"))); // should be 80304878568059106339100173465998353718

		/*
		temp.copy(a1);
		temp.modInvV1(b1);
		Log:log("BigIntModInvTests() v1= " + temp.toString(10) + "\n"); // 80304878568059106339100173465998353718

		temp.copy(a1);
		temp.modInvV2(b1);
		Log:log("BigIntModInvTests() v2= " + temp.toString(10) + "\n"); // 80304878568059106339100173465998353718

		temp.copy(a1);
		temp.modInv(b1);
		Log:log("BigIntModInvTests() v3= " + temp.toString(10) + "\n"); // 80304878568059106339100173465998353718
		*/
	}
}

class BigIntPrimeTests implements IUnitTest
{
	void run()
	{
		BigInt a();

		// test small not primes
		a.set(10);
		test(a.isPrime() == false);
		a.set(21);
		test(a.isPrime() == false);
		a.set(30);
		test(a.isPrime() == false);
		a.set(142);
		test(a.isPrime() == false);
		a.set(10983); // 3 * 3661
		test(a.isPrime() == false);

		// test small primes
		a.set(3);
		test(a.isPrime() == true);
		a.set(5);
		test(a.isPrime() == true);
		a.set(11);
		test(a.isPrime() == true);
		a.set(23);
		test(a.isPrime() == true);
		a.set(37);
		test(a.isPrime() == true);
		a.set(379);
		test(a.isPrime() == true);

		// test large not-primes
		a.setFromBase10String("3837273749839394499292921");
		test(a.isPrime() == false);
		a.setFromBase10String("383727383190893944992929214821");
		test(a.isPrime() == false);

		// test large are-primes
		a.setFromBase10String("900900900900990990990991");
		test(a.isPrime() == true);
		a.setFromBase10String("201487636602438195784363");
		test(a.isPrime() == true);
	}
}

class BigIntProbablyPrimeTests implements IUnitTest
{
	void run()
	{
		BigInt a();

		// test small not primes
		a.set(10);
		test(a.isProbablyPrime() == false);
		a.set(21);
		test(a.isProbablyPrime() == false);
		a.set(30);
		test(a.isProbablyPrime() == false);
		a.set(142);
		test(a.isProbablyPrime() == false);
		a.set(10983); // 3 * 3661
		test(a.isProbablyPrime() == false);

		// test small primes
		a.set(3);
		test(a.isProbablyPrime() == true);
		a.set(5);
		test(a.isProbablyPrime() == true);
		a.set(11);
		test(a.isProbablyPrime() == true);
		a.set(23);
		test(a.isProbablyPrime() == true);
		a.set(37);
		test(a.isProbablyPrime() == true);
		a.set(379);
		test(a.isProbablyPrime() == true);

		// test large not-primes
		a.setFromBase10String("3837273749839394499292921");
		test(a.isProbablyPrime() == false);
		a.setFromBase10String("383727383190893944992929214821");
		test(a.isProbablyPrime() == false);

		// test large are-primes
		a.setFromBase10String("900900900900990990990991");
		test(a.isProbablyPrime() == true);
		a.setFromBase10String("201487636602438195784363");
		test(a.isProbablyPrime() == true);
	}
}

class BigIntComparisonTests implements IUnitTest
{
	void run()
	{
		// compare small numbers
        BigInt a(u32(12));
		test(a.equals(u32(12)) == true);
		test(a.equals(i32(-12)) == false);
		a = BigInt(i32(-102));
		test(a.equals(i32(-12)) == false);
		test(a.numbers[0] == 102);
		test(a.sign == -1);
		test(a.numUsed == 1);
		test(a.equals(i32(-102)) == true);
		test(a.equals(i32(102)) == false);

		// compare BigInt small numbers
        a = BigInt(i64(12));
		BigInt b(i64(3));
		test(a.moreThan(b) == true);
		test(a.equals(b) == false);
		test(a.lessThan(b) == false);
		test(b.moreThan(a) == false);
		test(b.equals(a) == false);
		test(b.lessThan(a) == true);

		// compare same
		a = BigInt(i64(1029));
		b = BigInt(i64(1029));
		test(a.equals(b) == true);
		test(a.lessThan(b) == false);
		test(a.moreThan(b) == false);

		// compare negative
		a = BigInt(i64(-12));
		b = BigInt(i64(12));
		test(a.lessThan(b) == true);
		test(a.moreThan(b) == false);
		test(a.equals(b) == false);

		// compare negative
		a = BigInt(i64(-12));
		b = BigInt(i64(-3));
		test(a.lessThan(b) == true);
		test(a.moreThan(b) == false);
		test(a.equals(b) == false);

		// compare zero
		a = BigInt(i64(0));
		b = BigInt(i64(0));
		test(a.equals(a) == true);
		test(a.equals(b) == true);
		test(b.equals(a) == true);
		test(a.moreThan(b) == false);
		test(a.lessThan(b) == false);
		test(b.moreThan(a) == false);
		test(b.lessThan(a) == false);
		test(b.lessThanOrEqual(a) == true);
		test(b.moreThanOrEqual(a) == true);
		test(a.lessThanOrEqual(b) == true);
		test(a.moreThanOrEqual(b) == true);

		// compare zero and number
		a = BigInt(i64(0));
		b = BigInt(i64(2048));
		test(a.equals(b) == false);
		test(b.equals(a) == false);
		test(b.moreThan(a) == true);
		test(a.moreThan(b) == false);
	}
}

class BigIntFromStringTests implements IUnitTest
{
	void run()
	{
		// from strings (decimal system, AKA base10)
		BigInt a("0");
		test(a.isZero() == true);

        a.setFromBase10String("1");
		test(a.numUsed == 1);
		test(a.numbers[0] == 1);

		a.setFromBase10String("321");
		test(a.numUsed == 1);
		test(a.numbers[0] == 321);

		a.setFromBase10String("4294967296");
		test(a.numUsed == 2);
		test(a.numbers[0] == 0);
		test(a.numbers[1] == 1);

		a.setFromBase10String("4294967298");
		test(a.numUsed == 2);
		test(a.numbers[0] == 2);
		test(a.numbers[1] == 1);
		test(a.sign == 1);

		a.setFromBase10String("-4294967298");
		test(a.numUsed == 2);
		test(a.numbers[0] == 2);
		test(a.numbers[1] == 1);
		test(a.sign == -1);

		// binary base (AKA base2)
		a.setFromBase2String("1010");
		test(a.numUsed == 1);
		test(a.numbers[0] == 10);
		test(a.sign == 1);

		a.setFromBase2String("1001000011111011");
		test(a.numUsed == 1);
		test(a.numbers[0] == 0b1001000011111011);
		test(a.sign == 1);

		a.setFromBase2String("0b1001000011111011");
		test(a.numUsed == 1);
		test(a.numbers[0] == 0b1001000011111011);
		test(a.sign == 1);

		a.setFromBase2String("-1001000011111011");
		test(a.numUsed == 1);
		test(a.numbers[0] == 0b1001000011111011);
		test(a.sign == -1);

		a.setFromBase2String("-0b1001000011111011"); // weird format, but we support "-0b"
		test(a.numUsed == 1);
		test(a.numbers[0] == 0b1001000011111011);
		test(a.sign == -1);

		a.setFromBase2String("+0b1001000011111011"); // weird format, but we support "+0b"
		test(a.numUsed == 1);
		test(a.numbers[0] == 0b1001000011111011);
		test(a.sign == 1);

		a.setFromBase2String("1001000011111011 0101000011111011 0101000011111100 0101111111111100"); //64 bit number, we allow spaces for numbers (clarity)
		test(a.numUsed == 2);
		test(a.numbers[0] == 0b01010000111111000101111111111100);
		test(a.numbers[1] == 0b10010000111110110101000011111011);
		test(a.sign == 1);

		// hexidecimal
		a.setFromBase16String("AABBcc00"); // no prefix
		test(a.numUsed == 1);
		test(a.numbers[0] == 0xAABBCC00);
		test(a.sign == 1);

		a.setFromBase16String("-AABBcc00"); // no prefix, -ve
		test(a.numUsed == 1);
		test(a.numbers[0] == 0xAABBCC00);
		test(a.sign == -1);

		a.setFromBase16String("0xAABBcc00"); // prefix
		test(a.numUsed == 1);
		test(a.numbers[0] == 0xAABBCC00);
		test(a.sign == 1);

		a.setFromBase16String("-0xAABBcc00"); // prefix, -ve
		test(a.numUsed == 1);
		test(a.numbers[0] == 0xAABBCC00);
		test(a.sign == -1);

		a.setFromBase16String("+0xAABBcc00"); // prefix, +ve
		test(a.numUsed == 1);
		test(a.numbers[0] == 0xAABBCC00);
		test(a.sign == 1);

		a.setFromBase16String("AABBDD00 8299110A 8299440A C509110A"); // 128 bit number with spaces
		test(a.numUsed == 4);
		test(a.numbers[0] == 0xC509110A);
		test(a.numbers[1] == 0x8299440A);
		test(a.numbers[2] == 0x8299110A);
		test(a.numbers[3] == 0xAABBDD00);
		test(a.sign == 1);

		// we also support just "set(String)" figureing out what base, with base10 default
		a.set("0xAABBDD008299110A"); // 64 bit hex number
		test(a.numUsed == 2);
		test(a.numbers[0] == 0x8299110A);
		test(a.numbers[1] == 0xAABBDD00);
		test(a.sign == 1);

		a.set("-0xaaBBDD008299110A"); // 64 bit hex number with sign
		test(a.numUsed == 2);
		test(a.numbers[0] == 0x8299110A);
		test(a.numbers[1] == 0xAABBDD00);
		test(a.sign == -1);

		a.set("1001"); // decimal number that looks binary ish
		test(a.numUsed == 1);
		test(a.numbers[0] == 1001);
		test(a.sign == 1);

		a.set("0b1001"); // binary prefix number
		test(a.numUsed == 1);
		test(a.numbers[0] == 9);
		test(a.sign == 1);

		// finally we also support "set(String, base)" explcitly specifying base
		a.set("1001", 2); // binary or decimal or hex?
		test(a.numUsed == 1);
		test(a.numbers[0] == 9); // binary
		test(a.sign == 1);

		a.set("-1001", 10); // binary or decimal or hex?
		test(a.numUsed == 1);
		test(a.numbers[0] == 1001); // decimal
		test(a.sign == -1);

		a.set("1001", 16); // binary or decimal or hex?
		test(a.numUsed == 1);
		test(a.numbers[0] == 4097); // hex
		test(a.sign == 1);
	}
}

class BigIntToStringTests implements IUnitTest
{
	void run()
	{
		// to strings (decimal system, AKA base10)

		//U64_MAX = 18446744073709551615;
        BigInt a("123456789123456789123456789123456789");
		test(a.toString().compare("123456789123456789123456789123456789") == true);

		BigInt b("000000000000000000000000000000000000");
		test(b.toString().compare("0") == true);

		BigInt c("000000000000000000000000000000000001");
		test(c.toString().compare("1") == true);

		BigInt d("-123456789123456789123456789123456789");
		test(d.sign == -1);
		test(d.numUsed > 1);
		test(d.toString().compare("-123456789123456789123456789123456789") == true);

		BigInt e("+123456789123456789123456789123456789"); // plus sign ignored
		test(e.toString().compare("123456789123456789123456789123456789") == true);

		BigInt f("  123456789123456789123456789123456789"); // leading whitespace ignored
		test(f.toString().compare("123456789123456789123456789123456789") == true);

		BigInt g("123456789123456789123456789123456789  "); // trailing whitespace ignored
		test(g.toString().compare("123456789123456789123456789123456789") == true);

		// to strings binary
		BigInt g("0b100001"); 
		test(g.toStringBase2().compare("100001") == true);

		BigInt g("0b1100011100000000100001000001111110000001110000001000100101010101"); 
		test(g.toStringBase2().compare("1100011100000000100001000001111110000001110000001000100101010101") == true);

		// to strings hexadecimal
		BigInt g("0xA1B2C3D4E5F61C2B3A");
		test(g.toStringBase16().compare("A1B2C3D4E5F61C2B3A") == true);

		BigInt g("0xA1B2C3D4E5F61C2B3A1234567890ABCDEF123409876"); 
		test(g.toStringBase16().compare("A1B2C3D4E5F61C2B3A1234567890ABCDEF123409876") == true);
	}
}

class BigIntGenerateFastRandomTests implements IUnitTest
{
	void run()
	{
        BigInt a();
		BigInt b();

		// generate numbers of certain bit length

		a = BigInt:generateFastRandom(2);
		test(a.numUsed == 1);
		test(a.getBitLength() <= 2);
		test(a.numbers[0] >= 0 && a.numbers[0] <= 3);

		a = BigInt:generateFastRandom(8);
		test(a.numUsed == 1);
		test(a.getBitLength() <= 8);
		test(a.numbers[0] >= 0 && a.numbers[0] <= 255);

		a = BigInt:generateFastRandom(64);
		test(a.numUsed == 2); // 1 in 4 billion chance of being numUsed == 1 :-/
		test(a.getBitLength() <= 64);

		b = BigInt:generateFastRandom(64);
		test(b.numbers[0] != a.numbers[0]); // 1 in 4 billion chance of being same

		// generate numbers within a range

		a = BigInt:generateFastRandom(BigInt("102"), BigInt("4921"));
		test(a.numUsed == 1);
		test(a.getBitLength() >= 6 && a.getBitLength() <= 15);
		test(a.numbers[0] >= 102 && a.numbers[0] <= 4921);

		a = BigInt:generateFastRandom(BigInt("102283761010010192828738383"), BigInt("991002283761010010192828738383"));
		test(a.moreThanOrEqual(BigInt("102283761010010192828738383")) && a.lessThanOrEqual(BigInt("991002283761010010192828738383")));
	}
}

class BigIntEndianTests implements IUnitTest
{
	void run()
	{
        BigInt a1("1092844892226643732781819294049484848392083766527811818198299323244569943949494930");

		u8[] aBytesBig = a1.asBytesBigEndian();
		BigInt a2();
		a2.setFromBytesBigEndian(aBytesBig);
		test(a1.equals(a2) == true);

		u8[] aBytesLittle = a2.asBytesLittleEndian();
		BigInt a3();
		a3.setFromBytesLittleEndian(aBytesLittle);
		test(a1.equals(a3) == true);
	}
}
/* Slow 
class BigIntGenRandomPrimeTests implements IUnitTest
{
	void run()
	{
		f64 startTime = System:getTime();
		for(u64 n=0; n<3; n++)
		{
			//BigInt prime = BigInt:randomProbablePrimeOld(1024);
		}
		f64 elapsedTime = System:getTime() - startTime;

		//Log:log("\nBigIntGenRandomPrimeTests time to generate 1024 bit prime (old): " + String<u8>:formatNumber(elapsedTime / 10.0) + " ms \n");

		startTime = System:getTime();
		for(u64 n=0; n<3; n++)
		{
			BigInt prime = BigInt:randomProbablePrime(1024);
		}
		elapsedTime = System:getTime() - startTime;

		Log:log("BigIntGenRandomPrimeTests time to generate 1024 bit prime (new): " + String<u8>:formatNumber(elapsedTime / 10.0) + " ms \n\n");
	}
}*/

class BigIntPerformanceTests implements IUnitTest
{
	void run()
	{
		f64 startTime   = 0.0;
		f64 elapsedTime = 0.0;
		String<u8> results();

		//BigInt:randFast = RandomFast(); // want consistent results

		// 2048 bit numbers specified in hex
		BigInt a0("0xE234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD"); 
		BigInt b0("0xF134ABCD2234ABCD3234ABCD4234ABCF 1134ABCD2234ABCD3234ABCD4234ABCF 1934ABCD2234ABCD3234ABCD4234ABCF 1934ABCD2234ABCD3234ABCD4234ABCF 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD");
		BigInt c0("0xE234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD 1234ABCD2234ABCD3234ABCD4234ABCD");
		test(a0.numUsed == 64 && a0.getBitLength() == 2048);
		test(b0.numUsed == 64 && b0.getBitLength() == 2048);
		test(c0.numUsed == 64 && c0.getBitLength() == 2048);

		// 128 bit numbers
		BigInt d128("0xFABCDEF4568901927489AABB7839AB64");
		test(d128.getBitLength() == 128);

		// Test #1 - add
        BigInt a(a0); // 256 bytes, 64 U32s
		BigInt b(b0);
		BigInt c(c0);
		startTime = System:getTime();
		for(u32 x=0; x<1000; x++)
		{
			c.copy(a);
			c.add(b);
		}
		elapsedTime = System:getTime() - startTime;
		results += "Add 1000x 2048 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #2 - subtract
        a.copy(a0);
		b.copy(b0);
		startTime = System:getTime();
		for(u32 x=0; x<1000; x++)
		{
			c.copy(a0);
			c.subtract(b);
		}
		elapsedTime = System:getTime() - startTime;
		results += "Subtract 1000x 2048 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #3 - shift right
        a.copy(a0);
		b.copy(b0);
		startTime = System:getTime();
		for(u32 x=0; x<1000; x++)
		{
			c.copy(a0);
			c.shiftRight(300);
		}
		elapsedTime = System:getTime() - startTime;
		results += "ShiftRight-300 1000x 2048 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #4 - shift left
        a.copy(a0);
		b.copy(b0);
		startTime = System:getTime();
		for(u32 x=0; x<1000; x++)
		{
			c.copy(a0);
			c.shiftLeft(266);
		}
		elapsedTime = System:getTime() - startTime;
		results += "ShiftLeft-266 1000x 2048 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #5 - multiply
        a.copy(a0);
		b.copy(b0);
		startTime = System:getTime();
		for(u32 x=0; x<1000; x++)
		{
			c.copy(a0);
			c.multiply(b);
		}
		elapsedTime = System:getTime() - startTime;
		results += "Multiply 1000x 2048 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #6 - divide
        a.copy(a0);
		b.copy(b0);
		startTime = System:getTime();
		for(u32 x=0; x<10; x++)
		{
			c.copy(a0);
			b.copy(b0);
			b.shiftRight(1024); // tiny compared to c now, realistic divide operation...
			c.divide(b);
		}
		elapsedTime = System:getTime() - startTime;
		results += "Divide 10x 2048 / 1024 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #7 - modulo
        a.copy(a0);
		b.copy(b0);
		startTime = System:getTime();
		for(u32 x=0; x<10; x++)
		{
			c.copy(a0);
			b.copy(b0);
			b.shiftRight(1024); // tiny compared to c now, realistic divide operation...
			c.modulo(b);
		}
		elapsedTime = System:getTime() - startTime;
		results += "Modulo 10x 2048 % 1024 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #8 - moduloPower
        a.copy(a0);
		b.copy(b0);
		startTime = System:getTime();
		for(u32 x=0; x<1000; x++)
		{
			c.copy(a0);
			c.moduloPower(b, a);
		}
		elapsedTime = System:getTime() - startTime;
		results += "modPow 1000x 2048 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #9 - generate random numbers (fast)
		startTime = System:getTime();
		for(u32 x=0; x<1000; x++)
		{
			c = BigInt:generateFastRandom(2048);
			test(c.isZero() == false);
		}
		elapsedTime = System:getTime() - startTime;
		results += "fastRandom 1000x 2048 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #10 - generate true random numbers
		startTime = System:getTime();
		for(u32 x=0; x<10; x++)
		{
			c = BigInt:generateTrueRandom(2048);
			test(c.isZero() == false);
			//results += "2048 bit true random: " + c.toString(16) + "\n";
		}
		elapsedTime = System:getTime() - startTime;
		results += "trueRandom 10x 2048 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #11 - generate 64 bit probable random primes - this test varies in execution a lot because of true randomness
		startTime = System:getTime();
		for(u32 x=0; x<5; x++)
		{
			c = BigInt:randomProbablePrime(64);
			test(c.isZero() == false);
		}
		elapsedTime = System:getTime() - startTime;
		results += "randomProbablePrime 5x 64 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #12 - generate 128 bit probable random primes - this test varies in execution a lot because of true randomness
		startTime = System:getTime();
		for(u32 x=0; x<1; x++)
		{
			c = BigInt:randomProbablePrime(128);
		}
		elapsedTime = System:getTime() - startTime;
		results += "randomProbablePrime 1x 128 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #13 - generate 512 bit probable random primes - this test varies in execution a lot because of true randomness
		startTime = System:getTime();
		for(u32 x=0; x<1; x++)
		{
			c = BigInt:randomProbablePrime(512);
			results += "512-bit prime: " + c.toString(10) + "\n";
		}
		elapsedTime = System:getTime() - startTime;
		results += "randomProbablePrime 1x 512 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";
		
		// Test #14 -  This test doesn't vary much because no true randoms are used
		BigInt:setRandomSeed(0);
		startTime = System:getTime();
		//HVM:startPerfProfiling();
		for(u32 x=0; x<1; x++)
		{
			test(BigInt("0xE420DED52FC76FE4E0AB6CEE1E340763").isProbablyPrime() == true);
			test(BigInt("0x6725B4D2377AE6E4BC7AF5D93EA57125").isProbablyPrime() == true);
			test(BigInt("0x81C40DF223837A057DDAE568A0C199B5").isProbablyPrime() == true);
			test(BigInt("0x9DEE2F4174F21907B2F56EDAF10E42F3").isProbablyPrime() == true);
			test(BigInt("0x3105CC2A5BDD0F59FBBECAA5A9366BE5").isProbablyPrime() == true);
			test(BigInt("0xBEFEDD4D6A86B46EEEA4FBE8758BA90F").isProbablyPrime() == true);
			test(BigInt("0xF145FE5A16C872A2C54386A34934FAB3").isProbablyPrime() == true);
			test(BigInt("0x9CAEFC3CEF82658C9365AB52E20C52EB").isProbablyPrime() == true);
			test(BigInt("0xBE9551ADCED0AC43EFCE6FBE46242E1B").isProbablyPrime() == true);
			test(BigInt("0x2BE85DF4D9C7A220ECC1A27016266605").isProbablyPrime() == true);
		}
		//HVM:stopPerfProfiling();
		//String<u8> xmlReport = HVM:getPerfProfilingReport();
		//results += "HRT Profiling report\n" + xmlReport + "\n";
		elapsedTime = System:getTime() - startTime;
		results += "testProbablyPrime 10x 128 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		// Test #15 -  This test doesn't vary much because no true randoms are used
		BigInt:setRandomSeed(0);
		startTime = System:getTime();
		HVM:startPerfProfiling();
		for(u32 x=0; x<1; x++)
		{
			test(BigInt("0xa81fd5f5dd99cdeea79de85b97455ebfc8e3b6978f704c8f174deee0faf02eba17ae4d8c988aaf0f92fc4ac3ff7f3f4e2e0c99b07bd81d9d5d624e8249fb43b7").isProbablyPrime() == true);
			//test(BigInt("0x897abdb842d9c33672f85ef848eb5d0bb3dc87fc8812ca56cd1fbae5f435381e07bc7cf8fbfb2554e6fe96cfdf7542c16040574a10506ce28eba5d1b4bc5269f").isProbablyPrime() == true);
			//test(BigInt("0xef3634adc8007cee75069acdb0efcd3c4787e409bd40103d977992a1433d1ad42096ce0f7ca59e23e9b09512e354efdd80cad8f739a062c3df55f4d136d147e7").isProbablyPrime() == true);
			//test(BigInt("0xe27025fc64c6732680d769b8a6547680488649c0a6a9469be50940b1a490f99a742098c5d37da9055d2401d4a1a7ba1e573ff47abd66536b0a4854fdf6b82db5").isProbablyPrime() == true);
			//test(BigInt("0xcc7b22ea3e3ccc6176537d627bdd6cd148eace3a466d15cee017f20ba0f25e717ee1082b5f1b7d5f9722ff8397beaf5e0901adcfa02f89861a407fd8755bf48f").isProbablyPrime() == true);
		}
		HVM:stopPerfProfiling();
		String<u8> xmlReport = HVM:getPerfProfilingReport();
		results += "HRT Profiling report\n" + xmlReport + "\n";
		elapsedTime = System:getTime() - startTime;
		results += "testProbablyPrime 1x 512 bit numbers time: " + String<u8>:formatNumber(elapsedTime) + " ms \n";

		//Log:log("BigInt Performance Results:\n" + results + "\n");

		// i7 9700k results Dec 22 2019
		/*
		i7 9700k results Dec 22 2019

		BASELINE RESULTS:
		Add 1000x 2048 bit numbers time: 0.43 ms 
		Subtract 1000x 2048 bit numbers time: 9.66 ms 
		ShiftRight-300 1000x 2048 bit numbers time: 1.57 ms 
		ShiftLeft-266 1000x 2048 bit numbers time: 1.89 ms 
		Multiply 1000x 2048 bit numbers time: 2022.53 ms 
		Divide 1000x 2048 bit numbers time: 1.64 ms // dividing by 2048 bit divisor is useless test
		modPow 1000x 2048 bit numbers time: 10.15 ms 
		fastRandom 1000x 2048 bit numbers time: 111.33 ms // there was a bug here where extra u32 was added to 2048 bit number causing a stupid extra shift operation
		trueRandom 10x 2048 bit numbers time: 0.50 ms 

		// Reference : with debug=0
		Add 1000x 2048 bit numbers time: 0.20 ms               / Java BigInteger time: 0.14 ms
		Subtract 1000x 2048 bit numbers time: 0.23 ms          / Java BigInteger time: 0.13 ms
		ShiftRight-300 1000x 2048 bit numbers time: 0.31 ms    / Java BigInteger time: 0.41 ms
		ShiftLeft-266 1000x 2048 bit numbers time: 0.39 ms     / Java BigInteger time: 0.16 ms
		Multiply 1000x 2048 bit numbers time: 23.13 ms         / Java BigInteger time: 2.52 ms
		Divide 10x 2048 / 1024 bit numbers time: 2.37 ms       / Java BigInteger time: 0.02 ms
		Modulo 10x 2048 % 1024 bit numbers time: 2.27 ms       / Java BigInteger time: 0.02 ms
		modPow 1000x 2048 bit numbers time: 1.67 ms            / Java BigInteger time: 0.24 ms
		fastRandom 1000x 2048 bit numbers time: 1.97 ms 
		trueRandom 10x 2048 bit numbers time: 0.13 ms 
		randomProbablePrime 5x 64 bit numbers time: 50.21 ms 
		randomProbablePrime 1x 128 bit numbers time: 249.49 ms 
		testProbablyPrime 10x 128 bit numbers time: 299.91 ms 
		testProbablyPrime 1x 512 bit numbers time: 2019 ms     / Java BigInteger time: 78 ms

		// After adding new division algorithm (64/32 bits top) : with debug=0
		Add 1000x 2048 bit numbers time: 0.20 ms               / Java BigInteger time: 0.14 ms
		Subtract 1000x 2048 bit numbers time: 0.23 ms          / Java BigInteger time: 0.13 ms
		ShiftRight-300 1000x 2048 bit numbers time: 0.31 ms    / Java BigInteger time: 0.41 ms
		ShiftLeft-266 1000x 2048 bit numbers time: 0.39 ms     / Java BigInteger time: 0.16 ms
		Multiply 1000x 2048 bit numbers time: 23.13 ms         / Java BigInteger time: 2.52 ms
		Divide 10x 2048 / 1024 bit numbers time: 0.44 ms       / Java BigInteger time: 0.02 ms
		Modulo 10x 2048 % 1024 bit numbers time: 0.34 ms       / Java BigInteger time: 0.02 ms
		modPow 1000x 2048 bit numbers time: 1.67 ms            / Java BigInteger time: 0.24 ms
		fastRandom 1000x 2048 bit numbers time: 1.97 ms 
		trueRandom 10x 2048 bit numbers time: 0.13 ms 
		randomProbablePrime 5x 64 bit numbers time: 50.21 ms 
		randomProbablePrime 1x 128 bit numbers time: 32.22 ms 
		testProbablyPrime 10x 128 bit numbers time: 93.98 ms   / Java BigInteger time: 46.9 ms
		testProbablyPrime 1x 512 bit numbers time: 376.47 ms   / Java BigInteger time: 78 ms

		// After divide optimizations (bit check)
		BigInt Performance Results:
		Add 1000x 2048 bit numbers time: 0.20 ms 
		Subtract 1000x 2048 bit numbers time: 0.23 ms 
		ShiftRight-300 1000x 2048 bit numbers time: 0.31 ms 
		ShiftLeft-266 1000x 2048 bit numbers time: 0.39 ms 
		Multiply 1000x 2048 bit numbers time: 23.32 ms 
		Divide 10x 2048 / 1024 bit numbers time: 0.40 ms 
		Modulo 10x 2048 % 1024 bit numbers time: 0.35 ms 
		modPow 1000x 2048 bit numbers time: 1.77 ms 
		fastRandom 1000x 2048 bit numbers time: 1.98 ms 
		trueRandom 10x 2048 bit numbers time: 0.12 ms 
		randomProbablePrime 5x 64 bit numbers time: 43.00 ms 
		randomProbablePrime 1x 128 bit numbers time: 28.65 ms 
		testProbablyPrime 10x 128 bit numbers time: 92.16 ms 

		// After porting divide optimizations (bit check) to modulo
		Add 1000x 2048 bit numbers time: 0.20 ms 
		Subtract 1000x 2048 bit numbers time: 0.23 ms 
		ShiftRight-300 1000x 2048 bit numbers time: 0.31 ms 
		ShiftLeft-266 1000x 2048 bit numbers time: 0.41 ms 
		Multiply 1000x 2048 bit numbers time: 23.21 ms 
		Divide 10x 2048 / 1024 bit numbers time: 0.39 ms 
		Modulo 10x 2048 % 1024 bit numbers time: 0.31 ms 
		modPow 1000x 2048 bit numbers time: 1.75 ms 
		fastRandom 1000x 2048 bit numbers time: 1.97 ms 
		trueRandom 10x 2048 bit numbers time: 0.12 ms 
		randomProbablePrime 5x 64 bit numbers time: 45.70 ms 
		randomProbablePrime 1x 128 bit numbers time: 14.16 ms 
		testProbablyPrime 10x 128 bit numbers time: 94.67 ms 
		testProbablyPrime 1x 512 bit numbers time: 387.12 ms 
		
		Optimizing Prime Number Generation
		testProbablyPrime 10x 128 bit numbers time: 2723.94 ms - baseline (run #2 2759.67 ms, run #3 2725.46 ms etc.)
		testProbablyPrime 10x 128 bit numbers time: 2364.31 ms - after optimizing absDifference() to not allocate memory for new BigInt (run #2 2339.92 ms)
		testProbablyPrime 10x 128 bit numbers time: 2325.93 ms - after optimizing copy() to not overwrite zeros
		testProbablyPrime 10x 128 bit numbers time: 2317.45 ms - after optimizing modulo() not to allocate memory for new BigInt
		testProbablyPrime 10x 128 bit numbers time: 1810.47 ms - after debugLevel=0 instead of 1
		testProbablyPrime 10x 128 bit numbers time: 2508.53 ms - using shared cached vars in divide...didn't help, made things worse (probably because globals slower to access)
		testProbablyPrime 10x 128 bit numbers time: 2276.85 ms - divide() optimizations, but no shared cache vars
		testProbablyPrime 10x 128 bit numbers time: 1906.74 ms - sized b2nCount.numbers to be large from start so it isn't resized like 2048/32 times (run #2 1985.43 ms)
		testProbablyPrime 10x 128 bit numbers time: 1777.97 ms - optimized while loop cmp exp in divide() to cmp bit lengths instead of using call to moreThan()
		testProbablyPrime 10x 128 bit numbers time: 1750.02 ms - remove some newly unused bits from divide()
		testProbablyPrime 10x 128 bit numbers time: 1627.80 ms - subtract() removed unneccessary setNumUsed()
		testProbablyPrime 10x 128 bit numbers time: 1622.00 ms - subtract() condense if/else statements
		testProbablyPrime 10x 128 bit numbers time: 1606.47 ms - 64 bit indices / comparisons
		testProbablyPrime 10x 128 bit numbers time: 1610.46 ms - subtract simplifications
		testProbablyPrime 10x 128 bit numbers time: 1599.78 ms - adjust number of k rounds of miller-rabin to suit size (bit-length) of numbers
		testProbablyPrime 10x 128 bit numbers time:   94.67 ms - Division algorithm improvements
		*/
	}
}