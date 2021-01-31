////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// ECC
////////////////////////////////////////////////////////////////////////////////////////////////////

// Elliptic Curve Cryptography. Constants for named curves etc.
class ECC
{
    const u8 CURVE_NULL      = 0;
    const u8 CURVE_SECP256R1 = 1;
    const u8 CURVE_SECP384R1 = 2;

    // Get string name for curve ID.
    shared String<u8> curveIDToString(u8 curveID)
    {
        if(curveID == ECC:CURVE_SECP256R1)
            return "SECP256R1";
        if(curveID == ECC:CURVE_SECP384R1)
            return "SECP384R1";

        return "UNKNOWN";
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// ECDSAPublicKey
////////////////////////////////////////////////////////////////////////////////////////////////////

// Elliptic Curve Digital Signature Algorithm. For message/software signing.
class ECDSAPublicKey
{
    u8 curveID = ECC:CURVE_NULL;
    BigInt x();
    BigInt y();

    // Construct empty key.
    void constructor()
    {

    }

    // Copy constructor.
    void constructor(ECDSAPublicKey k)
    {

    }

    // Human readable string repsentation of ECDSA.
    String<u8> toString()
    {
        String<u8> s(128);

        s.append("Curve: " + ECC:curveIDToString(curveID) + "\n");

        if(x != null)
            s.append("X: " + x.toString(16) + "\n");

        if(y != null)
            s.append("Y: " + y.toString(16) + "\n");

        return s;
    }
}